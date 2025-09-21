# CloudFlare Pages Project Setup

This document provides step-by-step instructions for setting up the CloudCurio application on CloudFlare Pages.

## Prerequisites

1. CloudFlare account
2. GitHub repository with the CloudCurio code
3. Domain name (cloudcurio.cc) configured in CloudFlare

## Step 1: Create CloudFlare Pages Project

1. Log in to your CloudFlare dashboard
2. Navigate to Workers & Pages
3. Click "Create application"
4. Select "Pages" and click "Connect to Git"
5. Connect to your GitHub account
6. Select the repository (cbwinslow/cloudcurio-next-blog)
7. Configure the project settings:
   - Project name: `cloudcurio-blog`
   - Production branch: `main` (or `master`)
   - Build settings:
     - Build command: `npm run build`
     - Build output directory: `.next`
     - Root directory: `/` (leave empty)

## Step 2: Configure Build Settings

In the CloudFlare Pages project settings:

1. Go to Settings > Build & deployments
2. Under "Build configurations", ensure:
   - Framework preset: Next.js
   - Build command: `npm run build`
   - Build output directory: `.next`

## Step 3: Set Up Environment Variables

Navigate to Settings > Environment Variables and add the following variables:

| Variable Name | Value | Encrypted |
|---------------|-------|-----------|
| DATABASE_URL | Your database connection string | Yes |
| NEXTAUTH_SECRET | Your NextAuth secret | Yes |
| GITHUB_ID | Your GitHub OAuth app client ID | Yes |
| GITHUB_SECRET | Your GitHub OAuth app client secret | Yes |
| STRIPE_SECRET_KEY | Your Stripe secret key | Yes |
| STRIPE_PRICE_PRO | Your Stripe price ID | No |
| STRIPE_WEBHOOK_SECRET | Your Stripe webhook secret | Yes |
| NEXT_PUBLIC_APP_URL | https://cloudcurio.cc | No |
| WORKER_TOKEN | Your worker authentication token | Yes |
| GITHUB_WEBHOOK_SECRET | Your GitHub webhook secret | Yes |
| GITLAB_WEBHOOK_TOKEN | Your GitLab webhook token | Yes |

## Step 4: Configure Custom Domain

1. Go to Settings > Custom domains
2. Add domain: `cloudcurio.cc`
3. Follow the DNS configuration instructions provided by CloudFlare

## Step 5: Set Up GitHub Secrets

In your GitHub repository:

1. Go to Settings > Secrets and variables > Actions
2. Add the following repository secrets:

| Secret Name | Value |
|-------------|-------|
| CLOUDFLARE_API_TOKEN | Your CloudFlare API token |
| CLOUDFLARE_ACCOUNT_ID | Your CloudFlare account ID |
| GITHUB_TOKEN | Your GitHub token (usually provided automatically) |

## Step 6: Trigger Deployment

1. Make a small change to trigger a new build
2. Push to the main branch
3. Monitor the deployment in the CloudFlare dashboard

## Troubleshooting

### Build Issues
- Ensure all dependencies are correctly listed in package.json
- Check that the build command runs successfully locally
- Verify environment variables are correctly set

### Environment Variables
- Make sure sensitive variables are marked as encrypted
- Verify that all required variables are set

### Domain Issues
- Ensure DNS records are correctly configured
- Check that SSL/TLS encryption mode is set to "Full" or "Full (strict)"

### GitHub Actions
- Verify that the CloudFlare API token has the necessary permissions
- Check that the account ID is correct