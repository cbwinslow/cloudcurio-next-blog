# Setup Guide

## App
1. Copy `.env.example` → `.env.local` and fill values.
2. `pnpm i && pnpm prisma generate && pnpm db:push`
3. `pnpm dev`

## Webhooks
- GitHub: add webhook to `/api/github/webhook` with secret `GITHUB_WEBHOOK_SECRET`.
- GitLab: add webhook to `/api/gitlab/webhook` with token `GITLAB_WEBHOOK_TOKEN`.

## Billing
- Stripe product/price → set env values.
- Webhook: `/api/stripe/webhook` (set `STRIPE_WEBHOOK_SECRET`).

## Auth
- GitHub OAuth app callback: `/api/auth/callback/github`.

## Worker
- Run `scripts/cloudcurio_worker_install.sh` on cbwdellr720 with ZeroTier network ID.
- Set `CONTAINER_IMAGE=ghcr.io/<you>/cloudcurio-review:latest`.

## Testing
1. Run unit tests: `npm run test`
2. Run tests with coverage: `npm run test:coverage`
3. Run Python worker tests: `npm run test:worker` or `bash scripts/run-worker-tests.sh`
4. Run linting: `npm run lint`
5. Run type checking: `npm run type-check`

For CI/CD, GitHub Actions workflows are configured in `.github/workflows/`:
- `ci.yml`: Runs on pull requests and pushes to main/master branches
- `run-tests.yml`: Runs unit tests
- `code-coverage.yml`: Runs tests with coverage reporting
- `python-worker-tests.yml`: Runs Python worker tests
- `publish-container.yml`: Publishes container to GHCR
- `deploy-cloudflare.yml`: Deploys to CloudFlare Pages

## CloudFlare Deployment

To deploy to CloudFlare Pages:

1. Set up the required secrets in your GitHub repository:
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`
   - `GITHUB_TOKEN`

2. Configure environment variables in CloudFlare Pages project settings (see `docs/CLOUDFLARE_DEPLOYMENT.md`)

3. Push to the main branch to trigger automatic deployment

See `docs/CLOUDFLARE_DEPLOYMENT.md` for detailed instructions.
