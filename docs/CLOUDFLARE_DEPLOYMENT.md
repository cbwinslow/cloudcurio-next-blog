# CloudFlare Deployment Environment Variables

This document lists the environment variables required for deploying the CloudCurio application to CloudFlare Pages.

## Required Secrets (set in GitHub repository settings)

1. `CLOUDFLARE_API_TOKEN` - API token for CloudFlare authentication
2. `CLOUDFLARE_ACCOUNT_ID` - CloudFlare account identifier
3. `GITHUB_TOKEN` - GitHub token for deployment status reporting

## Environment Variables for Application

These variables should be set in the CloudFlare Pages project settings:

1. `DATABASE_URL` - Database connection string (SQLite for development, PostgreSQL for production)
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

## Setting Environment Variables in CloudFlare Pages

1. Go to the CloudFlare dashboard
2. Navigate to Workers & Pages
3. Select your project (cloudcurio-blog)
4. Go to Settings > Environment Variables
5. Add each variable with its corresponding value
6. Mark sensitive variables as "encrypted"

## Setting Secrets in GitHub

1. Go to your GitHub repository settings
2. Navigate to Secrets and variables > Actions
3. Click "New repository secret"
4. Add each required secret with its corresponding value