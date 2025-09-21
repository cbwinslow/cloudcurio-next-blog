\
#!/usr/bin/env bash
# CloudCurio Worker Installer (ZeroTier + Docker + NVIDIA + systemd)
# Usage:
#   sudo bash scripts/cloudcurio_worker_install.sh \
#     --api-base https://cloudcurio.cc \
#     --worker-token <TOKEN> \
#     --zt-net <ZEROTIER_NETWORK_ID> \
#     --container-image ghcr.io/<you>/cloudcurio-review:latest \
#     --gpu-mapping '{"rtx3060":"0","k80:0":"1","k80:1":"2","k40":"3"}' \
#     --gpu-classes '{"rtx3060":"quick","k80:0":"heavy","k80:1":"heavy","k40":"legacy"}'

set -euo pipefail

API_BASE="http://localhost:3000"
WORKER_TOKEN=""
ZT_NET=""
CONTAINER_IMAGE=""
GPU_MAPPING='{"rtx3060":"0","k80:0":"1","k80:1":"2","k40":"3"}'
GPU_CLASSES='{"rtx3060":"quick","k80:0":"heavy","k80:1":"heavy","k40":"legacy"}'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-base) API_BASE="$2"; shift 2;;
    --worker-token) WORKER_TOKEN="$2"; shift 2;;
    --zt-net) ZT_NET="$2"; shift 2;;
    --container-image) CONTAINER_IMAGE="$2"; shift 2;;
    --gpu-mapping) GPU_MAPPING="$2"; shift 2;;
    --gpu-classes) GPU_CLASSES="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

if [[ -z "$WORKER_TOKEN" ]]; then
  echo "[!] --worker-token is required" >&2
  exit 1
fi

echo "[CloudCurio] Installing dependencies..."

if command -v apt >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y curl ca-certificates gnupg lsb-release git python3 python3-pip python3-venv
  # Docker
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
  # NVIDIA toolkit
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -fsSL https://nvidia.github.io/libnvidia-container/experimental/$distribution/libnvidia-container-experimental.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' > /etc/apt/sources.list.d/nvidia-container-toolkit.list
  apt-get update -y
  apt-get install -y nvidia-container-toolkit
  nvidia-ctk runtime configure --runtime=docker || true
  systemctl restart docker
  # ZeroTier
  curl -s https://install.zerotier.com | bash
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y curl ca-certificates gnupg2 git python3 python3-pip
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
  curl -s https://install.zerotier.com | bash
else
  echo "[!] Unsupported OS. Please install Docker, NVIDIA toolkit, and ZeroTier manually." >&2
fi

if [[ -n "$ZT_NET" ]]; then
  zerotier-cli join "$ZT_NET" || true
  echo "[CloudCurio] Joined ZeroTier network: $ZT_NET (pending controller auth if required)"
fi

id -u cloudcurio &>/dev/null || useradd -m -s /bin/bash cloudcurio || true
usermod -aG docker cloudcurio || true

install -d -o cloudcurio -g cloudcurio /opt/cloudcurio
install -d -o cloudcurio -g cloudcurio /var/lib/cloudcurio/repos

# Write worker with embedded content
cat >/opt/cloudcurio/review_worker_v2.py <<'PY'
#!/usr/bin/env python3
from __future__ import annotations
import concurrent.futures as cf
import json, os, sys, shutil, subprocess, tempfile, time
from pathlib import Path
from typing import Optional
import urllib.request
def log(msg: str, **meta):
    print(json.dumps({"ts": time.strftime('%Y-%m-%dT%H:%M:%S'), "msg": msg, **meta})); sys.stdout.flush()
def run(cmd: list[str], cwd: Optional[str]=None, env: Optional[dict]=None, timeout=1800):
    p = subprocess.Popen(cmd, cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try: out, err = p.communicate(timeout=timeout); return p.returncode, out, err
    except subprocess.TimeoutExpired: p.kill(); return 124, '', 'timeout'
def http_json(method: str, url: str, data: Optional[dict]=None, token: Optional[str]=None) -> dict:
    headers = {'Content-Type':'application/json'}; 
    if token: headers['x-worker-token'] = token
    body = json.dumps(data).encode('utf-8') if data is not None else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=60) as r: return json.loads(r.read().decode('utf-8'))
def nvidia_smi(query: list[str]) -> list[list[str]]:
    fmt = ','.join(query); code, out, _ = run(['nvidia-smi', f'--query-gpu={fmt}', '--format=csv,noheader,nounits'])
    if code != 0: return []; lines = [l.strip() for l in out.splitlines() if l.strip()]; return [[c.strip() for c in line.split(',')] for line in lines]
class Device:
    def __init__(self, label: str, cuda_index: str, klass: str): self.label = label; self.index = cuda_index; self.klass = klass; self.busy=False; self.healthy=True
    def health_check(self):
        rows = nvidia_smi(['index','name','temperature.gpu','memory.total','memory.used','ecc.errors.corrected.aggregate','ecc.errors.uncorrected.aggregate'])
        try:
            i = int(self.index); r = rows[i]; temp = int(r[2]) if r[2].isdigit() else 0; uncorrected = int(r[6]) if r[6].isdigit() else 0
            self.healthy = (temp < 85) and (uncorrected == 0); return { 'temp': temp, 'uncorrected_ecc': uncorrected }
        except Exception: self.healthy = False; return { 'temp': None, 'uncorrected_ecc': None }
def clone_repo(url: str, work: Path) -> Path:
    dest = Path(tempfile.mkdtemp(prefix='cc_', dir=str(work))); code, _, err = run(['git','clone','--depth=1',url,str(dest)])
    if code != 0: raise RuntimeError(f'git clone failed: {err}'); return dest
HTML_HEAD = "<style>body{font-family:system-ui;margin:2rem auto;max-width:1100px}pre{background:#0b1020;color:#e5e7eb;padding:1rem;border-radius:12px;overflow:auto}</style>"
def static_analysis(repo: Path) -> str:
    blocks = []
    def blk(t, c): blocks.append(f\"<h2>{t}</h2><pre><code>{c}</code></pre>\")
    for cmd, title in [ (['git','ls-files'],'Repo Files'), (['bash','-lc','command -v ruff && ruff . --format text || echo ruff-missing'],'Ruff'), (['bash','-lc','command -v bandit && bandit -q -r . || echo bandit-missing'],'Bandit'), (['bash','-lc','command -v semgrep && semgrep --error -q || echo semgrep-missing'],'Semgrep') ]:
        code,out,err = run(cmd, cwd=str(repo)); blk(title,(out or err).strip())
    return ''.join(blocks)
def render_report(repo_url: str, gpu: Device, html: str) -> str:
    return f\"<html><head><meta charset='utf-8'>{HTML_HEAD}</head><body><h1>CloudCurio Review</h1><p><b>Repo:</b> {repo_url}<br/><b>GPU:</b> {gpu.label} (CUDA idx {gpu.index}, class {gpu.klass})</p>{html}<p style='color:#6b7280'>Generated by CloudCurio</p></body></html>\"
def run_in_container(image: str, gpu: Device, repo: Path) -> str:
    code,out,err = run(['docker','run','--rm','--gpus',f'device={gpu.index}','-v',f'{repo}:/work','-w','/work',image,'bash','-lc','echo container-ok && ls -1 | head -50']); return f\"Container({image}) exit={code}\\n{out or err}\"
def worker_loop(dev: Device, api: str, token: str, workdir: Path, image: str|None):
    while True:
        health = dev.health_check()
        if not dev.healthy: log('device unhealthy, draining', gpu=dev.label, health=health); time.sleep(5); continue
        claim = http_json('POST', f\"{api}/api/reviews/claim\", { 'gpu': dev.label, 'classes': [dev.klass] }, token); job = claim.get('job')
        if not job: time.sleep(3); continue
        jid = job['id']; repo_url = job['repoUrl']; log('job-claimed', id=jid, repo=repo_url, gpu=dev.label); repo = None
        try:
            os.environ['CUDA_VISIBLE_DEVICES'] = dev.index; repo = clone_repo(repo_url, workdir)
            analysis = static_analysis(repo); cont = ''; 
            if image: cont = f\"<h2>Container Step</h2><pre><code>{run_in_container(image, dev, repo)}</code></pre>\"
            report = render_report(repo_url, dev, analysis + cont); http_json('POST', f\"{api}/api/reviews/{jid}/complete\", { 'status':'done', 'content': report, 'gpu': dev.label }, token); log('job-complete', id=jid)
        except Exception as e:
            try: http_json('POST', f\"{api}/api/reviews/{jid}/complete\", { 'status':'error', 'error': str(e), 'gpu': dev.label }, token)
            except Exception: pass
            log('job-error', id=jid, error=str(e))
        finally:
            if repo: shutil.rmtree(repo, ignore_errors=True); time.sleep(1)
def main():
    api = os.environ.get('API_BASE','http://localhost:3000'); token = os.environ['WORKER_TOKEN']
    mapping = json.loads(os.environ.get('GPU_MAPPING','{\"rtx3060\":\"0\",\"k80:0\":\"1\",\"k80:1\":\"2\",\"k40\":\"3\"}'))
    classes = json.loads(os.environ.get('GPU_CLASSES','{\"rtx3060\":\"quick\",\"k80:0\":\"heavy\",\"k80:1\":\"heavy\",\"k40\":\"legacy\"}'))
    image = os.environ.get('CONTAINER_IMAGE'); workdir = Path(os.environ.get('REPOS_BASE_DIR','/var/lib/cloudcurio/repos')); workdir.mkdir(parents=True, exist_ok=True)
    devices = [Device(lbl, idx, classes.get(lbl,'quick')) for lbl,idx in mapping.items()]
    with cf.ThreadPoolExecutor(max_workers=len(devices)) as ex: 
        for d in devices: ex.submit(worker_loop, d, api, token, workdir, image); ex.shutdown()
if __name__ == '__main__': main()
PY
chmod +x /opt/cloudcurio/review_worker_v2.py
chown cloudcurio:cloudcurio /opt/cloudcurio/review_worker_v2.py

cat >/etc/systemd/system/cloudcurio-worker.service <<SERVICE
[Unit]
Description=CloudCurio GPU Review Worker v2
After=network-online.target docker.service
Wants=network-online.target docker.service
[Service]
Type=simple
Environment=API_BASE=${API_BASE}
Environment=WORKER_TOKEN=${WORKER_TOKEN}
Environment=GPU_MAPPING=${GPU_MAPPING}
Environment=GPU_CLASSES=${GPU_CLASSES}
Environment=REPOS_BASE_DIR=/var/lib/cloudcurio/repos
Environment=CONTAINER_IMAGE=${CONTAINER_IMAGE}
ExecStart=/usr/bin/python3 /opt/cloudcurio/review_worker_v2.py
Restart=always
RestartSec=5
User=cloudcurio
Group=cloudcurio
[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now cloudcurio-worker

echo "[CloudCurio] Install complete."
echo "API_BASE=${API_BASE}"
echo "ZeroTier: $(zerotier-cli info || true)"
