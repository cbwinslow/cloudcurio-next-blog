# Bitwarden to GitHub Secret Management Workflow

This document describes the complete workflow for managing CloudCurio secrets from Bitwarden to local development and GitHub deployment.

## Overview

The workflow consists of three main components:

1. **Bitwarden Extraction**: Extract secrets from Bitwarden vault
2. **Local Secret Management**: Store and manage secrets locally
3. **GitHub Deployment**: Push secrets to GitHub for CI/CD

## Workflow Components

### 1. Bitwarden Secret Extraction

The `scripts/extract-bitwarden-secrets.sh` script extracts secrets from your Bitwarden vault and prepares them for local use.

#### Prerequisites

- Bitwarden CLI (`bw`) installed
- Logged in and unlocked Bitwarden vault
- Secrets stored in Bitwarden with specific names

#### Required Bitwarden Items

1. **CloudFlare API Token** (password item)
2. **CloudFlare Account** (item with 'Account ID' custom field)
3. **GitHub Personal Access Token** (password item)
4. **CloudCurio Database URL** (password item)
5. **CloudCurio NextAuth Secret** (password item)
6. **CloudCurio GitHub OAuth** (item with 'Client ID' field and password)
7. **CloudCurio Stripe Secret** (password item)
8. **CloudCurio Stripe Product** (item with 'Price ID' custom field)
9. **CloudCurio Stripe Webhook** (password item)
10. **CloudCurio Worker Token** (password item)
11. **CloudCurio GitHub Webhook** (password item)
12. **CloudCurio GitLab Webhook** (password item)

#### Usage

```bash
# Extract secrets and save to local file
./scripts/extract-bitwarden-secrets.sh --save-local

# Extract secrets only (available as environment variables)
./scripts/extract-bitwarden-secrets.sh
```

### 2. Local Secret Management

The `scripts/setup-local-secrets.sh` script sets up a secure local environment for managing secrets.

#### Setup

```bash
# Set up complete local secret management
./scripts/setup-local-secrets.sh --all
```

This creates:
- Secure directory at `~/.config/cloudcurio`
- Template file for secrets
- Script to load secrets into environment
- Script to securely edit secrets

#### Using Local Secrets

```bash
# Edit your secrets (creates secrets.env from template)
~/.config/cloudcurio/edit-secrets.sh

# Load secrets into environment
source ~/.config/cloudcurio/load-secrets.sh
```

### 3. GitHub Secret Deployment

The `scripts/push-secrets-to-github.sh` script pushes local secrets to GitHub repository secrets.

#### Prerequisites

- Local secrets set up and loaded
- GitHub personal access token with `repo` scope

#### Usage

```bash
# Push local secrets to GitHub
./scripts/push-secrets-to-github.sh
```

This will add the following secrets to your GitHub repository:
- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

## Complete Workflow

1. **Set up Bitwarden**:
   - Store all required secrets in your Bitwarden vault
   - Use the exact names specified above

2. **Install Bitwarden CLI**:
   ```bash
   # Various installation methods available
   # See https://bitwarden.com/help/cli/
   ```

3. **Login and unlock Bitwarden**:
   ```bash
   bw login
   bw unlock
   ```

4. **Extract secrets from Bitwarden**:
   ```bash
   ./scripts/extract-bitwarden-secrets.sh --save-local
   ```

5. **Set up local secret management**:
   ```bash
   ./scripts/setup-local-secrets.sh --all
   ```

6. **Edit local secrets** (if needed):
   ```bash
   ~/.config/cloudcurio/edit-secrets.sh
   ```

7. **Load secrets into environment**:
   ```bash
   source ~/.config/cloudcurio/load-secrets.sh
   ```

8. **Push secrets to GitHub**:
   ```bash
   ./scripts/push-secrets-to-github.sh
   ```

## Security Considerations

1. **File Permissions**: All secret files are created with secure permissions (600 or 700)
2. **No Plain Text in Code**: Secrets are never stored in the repository
3. **Environment Isolation**: Secrets are only loaded when explicitly sourced
4. **Encrypted Storage**: GitHub secrets are encrypted by GitHub's systems
5. **API Key Authentication**: Use Bitwarden API keys for automated workflows

## Troubleshooting

### Common Issues

1. **Bitwarden CLI Not Found**: Install Bitwarden CLI from official sources
2. **Not Logged In**: Run `bw login` and `bw unlock`
3. **Missing Secrets**: Verify secret names in Bitwarden match expected names
4. **Permission Denied**: Check file permissions on secret files
5. **Python Dependencies**: Ensure `requests` and `pynacl` are installed

### Verification

To verify secrets are properly set up:

1. **Check Bitwarden Status**:
   ```bash
   bw status
   ```

2. **Verify Local Secrets**:
   ```bash
   source ~/.config/cloudcurio/load-secrets.sh
   echo $CLOUDFLARE_API_TOKEN  # Should show your token (be careful with output)
   ```

3. **Check GitHub Secrets**:
   - Go to GitHub repository Settings > Secrets and variables > Actions
   - Verify `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are present

## Automation

For automated workflows, you can combine these scripts:

```bash
#!/bin/bash
# Fully automated secret setup

# Login to Bitwarden (for automated environments)
export BW_CLIENTID=your_client_id
export BW_CLIENTSECRET=your_client_secret
bw login --apikey

# Unlock vault (you might need to handle master password differently in automation)
export BW_SESSION=$(bw unlock --raw)

# Extract secrets
./scripts/extract-bitwarden-secrets.sh --save-local

# Load secrets
source ~/.config/cloudcurio/load-secrets.sh

# Push to GitHub
./scripts/push-secrets-to-github.sh

# Clean up
bw lock
```

This workflow provides a secure, automated way to manage secrets from Bitwarden through local development to GitHub deployment.