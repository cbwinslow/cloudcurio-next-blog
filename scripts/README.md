# CloudFlare Deployment Secrets Setup

This directory contains scripts to programmatically add CloudFlare deployment secrets to your GitHub repository.

## Prerequisites

1. Python 3.x
2. pip package manager
3. GitHub personal access token with `repo` scope
4. CloudFlare API token
5. CloudFlare Account ID

## Scripts

### `add-github-secret.py`

A Python script that uses the GitHub API to add encrypted secrets to a repository.

Usage:
```bash
python3 add-github-secret.py \
    --owner <repository-owner> \
    --repo <repository-name> \
    --token <github-token> \
    --secret-name <secret-name> \
    --secret-value <secret-value>
```

### `setup-cloudflare-secrets.sh`

A shell script that automates the process of adding all required CloudFlare deployment secrets.

Usage:
```bash
# Set your GitHub token as an environment variable
export GITHUB_TOKEN=your_github_token

# Run the setup script
./setup-cloudflare-secrets.sh
```

The script will prompt you for:
1. CloudFlare API token
2. CloudFlare Account ID

## Required Secrets

The following secrets will be added to your GitHub repository:

1. `CLOUDFLARE_API_TOKEN` - Your CloudFlare API token
2. `CLOUDFLARE_ACCOUNT_ID` - Your CloudFlare account ID

## GitHub Personal Access Token

To create a GitHub personal access token:

1. Go to https://github.com/settings/tokens
2. Click "Generate new token"
3. Select the `repo` scope
4. Generate the token and copy it

## CloudFlare API Token

To get your CloudFlare API token and account ID:

1. Log in to your CloudFlare dashboard
2. Go to User Profile > API Tokens
3. Create a token with appropriate permissions for Pages
4. Your Account ID is available on the dashboard overview

## Running the Setup

```bash
# Set your GitHub token
export GITHUB_TOKEN=your_github_token

# Run the setup script
./setup-cloudflare-secrets.sh
```