# CloudCurio – Full Monorepo (Final)

This repo bundles the complete CloudCurio stack so you can push to GitHub and run:

- **Next.js app** (landing, blog stub, scripts CDN with raw endpoints, GitHub/GitLab webhooks, reviews UI, auth via GitHub, Stripe billing, gated chatbot)
- **Prisma** schema for Auth + Billing + Usage + Scripts + Reviews
- **GPU Review Worker v2** (parallel across RTX 3060, K80:0, K80:1, K40) + systemd unit
- **Analysis Container** (GHCR-ready Dockerfile + runner)
- **Installer** for cbwdellr720 (ZeroTier + Docker + NVIDIA Container Toolkit + worker)
- **Docs** for setup and compliance
- **Archive** of older versions and the enhanced landing template
- **Logos** under `public/logos/` (from your uploaded images)

## Quick Start

### 0) Prereqs
- Node 18+ and **pnpm** (or npm)
- Docker (for container build/publish)
- SQLite (dev) or Postgres (prod)
- On **cbwdellr720**: NVIDIA drivers + ZeroTier

### 1) Configure app
```bash
cp .env.example .env.local
```

### 2) Install deps & DB
```bash
pnpm i
pnpm prisma generate
pnpm db:push
```

### 3) Run app
```bash
pnpm dev
# http://localhost:3000
```

### 4) Scripts CDN
- Visit `/admin/scripts` and create a script (e.g., slug `bootstrap`).
- Usage on a fresh machine:
  ```bash
  curl -fsSL https://yourdomain/raw/scripts/bootstrap | bash
  ```

### 5) Container to GHCR
- The workflow under `.github/workflows/publish-container.yml` pushes:
  `ghcr.io/<your-github-username-or-org>/cloudcurio-review:latest`
- On push to `main` (changes under `container/`), it builds & publishes automatically.

### 6) Worker on cbwdellr720
```bash
sudo bash scripts/cloudcurio_worker_install.sh   --api-base https://cloudcurio.cc   --worker-token "<STRONG_TOKEN>"   --zt-net <YOUR_ZEROTIER_NETWORK_ID>   --container-image ghcr.io/<you>/cloudcurio-review:latest   --gpu-mapping '{"rtx3060":"0","k80:0":"1","k80:1":"2","k40":"3"}'   --gpu-classes '{"rtx3060":"quick","k80:0":"heavy","k80:1":"heavy","k40":"legacy"}'
# Logs:
journalctl -u cloudcurio-worker -f
```

### 7) Webhooks
- **GitHub** → Settings → Webhooks → URL: `https://yourdomain/api/github/webhook` (secret: `GITHUB_WEBHOOK_SECRET`)
- **GitLab** → Webhooks → URL: `https://yourdomain/api/gitlab/webhook` (token: `GITLAB_WEBHOOK_TOKEN`)

### 8) Auth (GitHub)
- Create a GitHub OAuth app:
  - Callback URL: `https://yourdomain/api/auth/callback/github`
- Set `GITHUB_ID`, `GITHUB_SECRET`, `NEXTAUTH_SECRET`

### 9) Billing (Stripe)
- Create Product + Price (Pro)
- Set `.env.local` values: `STRIPE_SECRET_KEY`, `STRIPE_PRICE_PRO`
- Add webhook endpoint to Stripe: `https://yourdomain/api/stripe/webhook` and set `STRIPE_WEBHOOK_SECRET`

### 10) Testing
- Run unit tests: `npm run test`
- Run tests with coverage: `npm run test:coverage`
- Run Python worker tests: `npm run test:worker`
- Run linting: `npm run lint`
- Run type checking: `npm run type-check`

See `docs/SETUP.md` and `docs/COMPLIANCE.md` for details.
