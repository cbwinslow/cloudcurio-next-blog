#!/bin/bash
# Script to add CloudFlare deployment secrets to GitHub repository

set -e

# Check if required tools are available
command -v python3 >/dev/null 2>&1 || { echo >&2 "Python 3 is required but not installed. Aborting."; exit 1; }
command -v pip >/dev/null 2>&1 || { echo >&2 "pip is required but not installed. Aborting."; exit 1; }

# Install required Python packages
echo "Installing required Python packages..."
pip install requests pynacl

# Get repository information
REPO_OWNER="cbwinslow"
REPO_NAME="cloudcurio-next-blog"

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Please set the GITHUB_TOKEN environment variable."
    echo "You can create a personal access token at: https://github.com/settings/tokens"
    echo "The token needs 'repo' scope permissions."
    exit 1
fi

# Prompt for CloudFlare API token
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "Please enter your CloudFlare API token:"
    read -s CLOUDFLARE_API_TOKEN
fi

# Prompt for CloudFlare Account ID
if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    echo "Please enter your CloudFlare Account ID:"
    read CLOUDFLARE_ACCOUNT_ID
fi

# Add secrets using the Python script
echo "Adding CloudFlare API token to GitHub secrets..."
python3 scripts/add-github-secret.py \
    --owner "$REPO_OWNER" \
    --repo "$REPO_NAME" \
    --token "$GITHUB_TOKEN" \
    --secret-name "CLOUDFLARE_API_TOKEN" \
    --secret-value "$CLOUDFLARE_API_TOKEN"

echo "Adding CloudFlare Account ID to GitHub secrets..."
python3 scripts/add-github-secret.py \
    --owner "$REPO_OWNER" \
    --repo "$REPO_NAME" \
    --token "$GITHUB_TOKEN" \
    --secret-name "CLOUDFLARE_ACCOUNT_ID" \
    --secret-value "$CLOUDFLARE_ACCOUNT_ID"

echo "Successfully added all required CloudFlare deployment secrets to GitHub!"
echo "You can now trigger a deployment by pushing to the main branch."