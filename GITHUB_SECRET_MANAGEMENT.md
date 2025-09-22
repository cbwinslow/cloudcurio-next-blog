# GitHub Secret Management for CloudFlare Deployment

This document provides instructions on how to use the scripts created to programmatically manage GitHub secrets for CloudFlare deployment.

## Overview

The repository now includes scripts to automate the process of adding CloudFlare deployment secrets to your GitHub repository. This eliminates the need to manually add secrets through the GitHub web interface.

## Files

1. `scripts/add-github-secret.py` - Python script that uses the GitHub API to add encrypted secrets
2. `scripts/setup-cloudflare-secrets.sh` - Shell script that automates the entire process
3. `scripts/README.md` - Detailed documentation for the scripts

## Prerequisites

1. Python 3.x
2. pip package manager
3. GitHub personal access token with `repo` scope
4. CloudFlare API token
5. CloudFlare Account ID

## Usage

### Method 1: Automated Setup (Recommended)

1. Ensure you have Python 3 and pip installed:
   ```bash
   python3 --version
   pip --version
   ```

2. Set your GitHub personal access token as an environment variable:
   ```bash
   export GITHUB_TOKEN=your_github_personal_access_token
   ```

3. Run the setup script:
   ```bash
   ./scripts/setup-cloudflare-secrets.sh
   ```

4. When prompted, enter your:
   - CloudFlare API token
   - CloudFlare Account ID

The script will:
- Install required Python packages (`requests` and `pynacl`)
- Add the `CLOUDFLARE_API_TOKEN` secret to your GitHub repository
- Add the `CLOUDFLARE_ACCOUNT_ID` secret to your GitHub repository

### Method 2: Manual Secret Addition

If you prefer to add secrets individually, you can use the Python script directly:

```bash
python3 scripts/add-github-secret.py \\
    --owner cbwinslow \\
    --repo cloudcurio-next-blog \\
    --token your_github_token \\
    --secret-name SECRET_NAME \\
    --secret-value secret_value
```

## GitHub Personal Access Token

To create a GitHub personal access token:

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give the token a descriptive name
4. Select the `repo` scope (this is required for managing repository secrets)
5. Click "Generate token"
6. Copy the generated token

## CloudFlare Credentials

### CloudFlare API Token

1. Log in to your CloudFlare dashboard
2. Go to User Profile > API Tokens
3. Click "Create Token"
4. Use the "Edit Cloudflare Workers" template or create a custom token with:
   - Permissions: `com.cloudflare.edge.functions.pages:edit`
   - Resources: Include the specific Pages project or use "All pages projects"
5. Continue to summary and create the token
6. Copy the token

### CloudFlare Account ID

1. Log in to your CloudFlare dashboard
2. The Account ID is displayed on the right side of the dashboard overview page
3. Alternatively, click on your account name in the dropdown menu to see the account ID

## Security Notes

1. Never commit personal access tokens or API keys to version control
2. Always use environment variables or secure input methods for sensitive data
3. The scripts handle encryption of secrets according to GitHub's security requirements
4. GitHub secrets are encrypted before storage and only decrypted during workflow runs

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure your GitHub token has the `repo` scope
2. **Package Installation Failures**: Make sure you have pip installed and up to date
3. **API Rate Limiting**: GitHub has rate limits for API requests; if you hit these, wait before retrying

### Verifying Secrets

To verify that secrets have been added successfully:

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. You should see the `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` secrets listed

## Bitwarden Integration

This repository also includes scripts for extracting secrets from Bitwarden and managing them locally:

1. **Bitwarden Extraction**: `scripts/extract-bitwarden-secrets.sh`
2. **Local Secret Management**: `scripts/setup-local-secrets.sh`
3. **GitHub Deployment**: `scripts/push-secrets-to-github.sh`

See `BITWARDEN_SECRET_WORKFLOW.md` for complete documentation on this workflow.

## Next Steps

After adding the secrets:

1. Push a change to the main branch to trigger the deployment workflow
2. Monitor the deployment progress in the GitHub Actions tab
3. Verify the deployment was successful in the CloudFlare dashboard