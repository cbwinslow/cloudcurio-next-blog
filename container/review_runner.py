#!/usr/bin/env python3
import os, subprocess, sys
from pathlib import Path
CSS = "<style>body{font-family:system-ui;margin:2rem auto;max-width:1100px;color:#111}h1{font-size:1.8rem;margin-bottom:1rem}h2{font-size:1.2rem;margin-top:1.25rem}pre{background:#0b1020;color:#e5e7eb;padding:1rem;border-radius:12px;overflow:auto}small{color:#6b7280}</style>"
def run(cmd, cwd=None):
    p = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True); out, _ = p.communicate(); return p.returncode, out
def section(t,b): print(f"<h2>{t}</h2><pre><code>{b}</code></pre>")
def main():
    repo = Path('/work')
    print("<html><head><meta charset='utf-8'>"+CSS+"</head><body>"); print("<h1>CloudCurio Container Analysis</h1>")
    if not repo.exists(): print("<p>Error: /work not mounted</p></body></html>"); sys.exit(2)
    code, out = run(["git","ls-files"], cwd=str(repo)); section("Repo Files", out.strip())
    code, out = run(["bash","-lc","command -v ruff && ruff . --format text || echo 'ruff missing'"], cwd=str(repo)); section("Ruff", out.strip())
    code, out = run(["bash","-lc","command -v bandit && bandit -q -r . || echo 'bandit missing'"], cwd=str(repo)); section("Bandit", out.strip())
    semgrep_cmd = "command -v semgrep && semgrep --error -q"; cfg = os.getenv("CC_SEMGREP_CONFIG")
    if cfg and (repo/cfg).exists(): semgrep_cmd = f"command -v semgrep && semgrep --error -q -f {cfg}"
    code, out = run(["bash","-lc", semgrep_cmd + " || echo 'semgrep missing'"], cwd=str(repo)); section("Semgrep", out.strip())
    if os.getenv("CC_ENABLE_CREWAI","false").lower() in {"1","true","yes"}: section("CrewAI","CrewAI placeholder – implement your pipeline here.")
    print("<small>Container done.</small></body></html>")
if __name__ == "__main__": main()
