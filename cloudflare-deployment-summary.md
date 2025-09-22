# CloudFlare Deployment Summary

This document summarizes all the files and configurations added to enable CloudFlare deployment for the CloudCurio application.

## Files Created

### Configuration Files
1. `wrangler.toml` - CloudFlare Workers configuration
2. `cloudflare.json` - CloudFlare Pages build configuration

### Documentation
1. `docs/CLOUDFLARE_DEPLOYMENT.md` - Environment variables and deployment instructions
2. `docs/CLOUDFLARE_PROJECT_SETUP.md` - Step-by-step project setup guide

### GitHub Actions Workflows
1. `.github/workflows/deploy-cloudflare.yml` - Workflow to deploy to CloudFlare Pages

### Automation Scripts
1. `scripts/add-github-secret.py` - Python script to programmatically add secrets to GitHub
2. `scripts/setup-cloudflare-secrets.sh` - Shell script to automate secret setup
3. `scripts/README.md` - Documentation for the automation scripts

## Files Modified
1. `docs/SETUP.md` - Updated with CloudFlare deployment instructions

## GitHub Actions Workflows

### CI Workflow (ci.yml)
- Runs on both pull requests and pushes to main/master branches
- Performs testing and building of the application
- Does not deploy to CloudFlare (separated for better control)

### CloudFlare Deployment Workflow (deploy-cloudflare.yml)
- Runs only after successful completion of CI workflow on main/master branches
- Builds the Next.js application
- Deploys to CloudFlare Pages using the cloudflare/pages-action

## Required GitHub Secrets

The following secrets need to be configured in the GitHub repository settings:

1. `CLOUDFLARE_API_TOKEN` - API token for CloudFlare authentication
2. `CLOUDFLARE_ACCOUNT_ID` - CloudFlare account identifier
3. `GITHUB_TOKEN` - GitHub token for deployment status reporting

## Required CloudFlare Environment Variables

The following environment variables need to be configured in the CloudFlare Pages project settings:

1. `DATABASE_URL` - Database connection string
2. `NEXTAUTH_SECRET` - Secret for NextAuth.js
3. `GITHUB_ID` - GitHub OAuth application client ID
4. `GITHUB_SECRET` - GitHub OAuth application client secret
5. `STRIPE_SECRET_KEY` - Stripe secret key for payment processing
6. `STRIPE_PRICE_PRO` - Stripe price ID for Pro plan
7. `STRIPE_WEBHOOK_SECRET` - Secret for Stripe webhook verification
8. `NEXT_PUBLIC_APP_URL` - Public URL of the application (https://cloudcurio.cc)
9. `WORKER_TOKEN` - Authentication token for worker communication
10. `GITHUB_WEBHOOK_SECRET` - Secret for GitHub webhook verification
11. `GITLAB_WEBHOOK_TOKEN` - Token for GitLab webhook verification

## Deployment Process

1. Code is pushed to the main branch
2. CI workflow runs tests and builds the application
3. If CI workflow succeeds, deploy-cloudflare.yml workflow is triggered
4. Application is built and deployed to CloudFlare Pages
5. Site is available at https://cloudcurio.cc

## Project Setup

To set up the CloudFlare Pages project:

1. Create a new Pages project in CloudFlare dashboard
2. Connect to the GitHub repository
3. Configure build settings:
   - Build command: `npm run build`
   - Build output directory: `.next`
4. Set up environment variables as documented in CLOUDFLARE_DEPLOYMENT.md
5. Configure custom domain (cloudcurio.cc)
6. Set up GitHub secrets as documented in CLOUDFLARE_DEPLOYMENT.md

## Automated Secret Setup

This repository includes scripts to programmatically add secrets to GitHub:

1. Ensure you have Python 3 and pip installed
2. Set your GitHub personal access token as an environment variable:
   ```bash
   export GITHUB_TOKEN=your_github_token
   ```
3. Run the setup script:
   ```bash
   ./scripts/setup-cloudflare-secrets.sh
   ```
4. When prompted, enter your CloudFlare API token and Account ID

## Troubleshooting

Common issues and solutions are documented in `docs/CLOUDFLARE_PROJECT_SETUP.md`.