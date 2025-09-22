#!/bin/bash
# Script to extract CloudCurio secrets from Bitwarden and prepare them for local and GitHub use

set -e

# Check if Bitwarden CLI is installed
if ! command -v bw &> /dev/null; then
    echo "Error: Bitwarden CLI (bw) is not installed."
    echo "Please install it from https://bitwarden.com/help/cli/"
    exit 1
fi

# Function to check if logged in to Bitwarden
check_bw_login() {
    if ! bw status | grep -q '"status":"unlocked"'; then
        echo "Bitwarden vault is not unlocked. Please login and unlock:"
        echo "  bw login                 # Login to Bitwarden"
        echo "  bw unlock                # Unlock your vault"
        echo "Or set BW_CLIENTID and BW_CLIENTSECRET for API key authentication"
        exit 1
    fi
}

# Function to extract secrets from Bitwarden
extract_secrets() {
    echo "Extracting secrets from Bitwarden..."
    
    # Try to get session key
    if [ -n "$BW_SESSION" ]; then
        SESSION_PARAM="--session $BW_SESSION"
    else
        SESSION_PARAM=""
    fi
    
    # Extract CloudFlare secrets
    echo "Extracting CloudFlare secrets..."
    CLOUDFLARE_API_TOKEN=$(bw get password "CloudFlare API Token" $SESSION_PARAM 2>/dev/null || echo "")
    CLOUDFLARE_ACCOUNT_ID=$(bw get item "CloudFlare Account" $SESSION_PARAM 2>/dev/null | jq -r '.fields[] | select(.name=="Account ID") | .value' 2>/dev/null || echo "")
    
    # Extract GitHub secrets
    echo "Extracting GitHub secrets..."
    GITHUB_TOKEN=$(bw get password "GitHub Personal Access Token" $SESSION_PARAM 2>/dev/null || echo "")
    
    # Extract application secrets
    echo "Extracting application secrets..."
    DATABASE_URL=$(bw get password "CloudCurio Database URL" $SESSION_PARAM 2>/dev/null || echo "")
    NEXTAUTH_SECRET=$(bw get password "CloudCurio NextAuth Secret" $SESSION_PARAM 2>/dev/null || echo "")
    GITHUB_ID=$(bw get item "CloudCurio GitHub OAuth" $SESSION_PARAM 2>/dev/null | jq -r '.fields[] | select(.name=="Client ID") | .value' 2>/dev/null || echo "")
    GITHUB_SECRET=$(bw get password "CloudCurio GitHub OAuth" $SESSION_PARAM 2>/dev/null || echo "")
    STRIPE_SECRET_KEY=$(bw get password "CloudCurio Stripe Secret" $SESSION_PARAM 2>/dev/null || echo "")
    STRIPE_PRICE_PRO=$(bw get item "CloudCurio Stripe Product" $SESSION_PARAM 2>/dev/null | jq -r '.fields[] | select(.name=="Price ID") | .value' 2>/dev/null || echo "")
    STRIPE_WEBHOOK_SECRET=$(bw get password "CloudCurio Stripe Webhook" $SESSION_PARAM 2>/dev/null || echo "")
    WORKER_TOKEN=$(bw get password "CloudCurio Worker Token" $SESSION_PARAM 2>/dev/null || echo "")
    GITHUB_WEBHOOK_SECRET=$(bw get password "CloudCurio GitHub Webhook" $SESSION_PARAM 2>/dev/null || echo "")
    GITLAB_WEBHOOK_TOKEN=$(bw get password "CloudCurio GitLab Webhook" $SESSION_PARAM 2>/dev/null || echo "")
    
    # Validate required secrets
    if [ -z "$CLOUDFLARE_API_TOKEN" ] || [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
        echo "Warning: CloudFlare secrets not found in Bitwarden"
    fi
    
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "Warning: GitHub token not found in Bitwarden"
    fi
    
    # Export secrets as environment variables
    export CLOUDFLARE_API_TOKEN
    export CLOUDFLARE_ACCOUNT_ID
    export GITHUB_TOKEN
    export DATABASE_URL
    export NEXTAUTH_SECRET
    export GITHUB_ID
    export GITHUB_SECRET
    export STRIPE_SECRET_KEY
    export STRIPE_PRICE_PRO
    export STRIPE_WEBHOOK_SECRET
    export WORKER_TOKEN
    export GITHUB_WEBHOOK_SECRET
    export GITLAB_WEBHOOK_TOKEN
    
    echo "Secrets extracted successfully!"
}

# Function to save secrets to a local file
save_local_secrets() {
    echo "Saving secrets to local file..."
    
    # Create a secure directory for secrets if it doesn't exist
    SECRETS_DIR="$HOME/.config/cloudcurio"
    mkdir -p "$SECRETS_DIR"
    
    # Create a secure file for secrets
    SECRETS_FILE="$SECRETS_DIR/secrets.env"
    touch "$SECRETS_FILE"
    chmod 600 "$SECRETS_FILE"
    
    # Write secrets to file
    cat > "$SECRETS_FILE" << EOF
# CloudCurio Secrets - Extracted from Bitwarden
# Last updated: $(date)

# CloudFlare Deployment
CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN
CLOUDFLARE_ACCOUNT_ID=$CLOUDFLARE_ACCOUNT_ID

# GitHub
GITHUB_TOKEN=$GITHUB_TOKEN

# Application Secrets
DATABASE_URL=$DATABASE_URL
NEXTAUTH_SECRET=$NEXTAUTH_SECRET
GITHUB_ID=$GITHUB_ID
GITHUB_SECRET=$GITHUB_SECRET
STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY
STRIPE_PRICE_PRO=$STRIPE_PRICE_PRO
STRIPE_WEBHOOK_SECRET=$STRIPE_WEBHOOK_SECRET
WORKER_TOKEN=$WORKER_TOKEN
GITHUB_WEBHOOK_SECRET=$GITHUB_WEBHOOK_SECRET
GITLAB_WEBHOOK_TOKEN=$GITLAB_WEBHOOK_TOKEN
EOF
    
    echo "Secrets saved to $SECRETS_FILE"
    echo "File permissions set to 600 (read/write for owner only)"
}

# Function to display usage instructions
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Extract CloudCurio secrets from Bitwarden and prepare them for local and GitHub use."
    echo ""
    echo "Options:"
    echo "  --save-local    Save secrets to a local file (~/.config/cloudcurio/secrets.env)"
    echo "  --help          Show this help message"
    echo ""
    echo "Requirements:"
    echo "  - Bitwarden CLI (bw) must be installed"
    echo "  - You must be logged in and unlocked to your Bitwarden vault"
    echo "  - Secrets must be stored in Bitwarden with the expected names"
    echo ""
    echo "Secret Names Expected in Bitwarden:"
    echo "  - 'CloudFlare API Token' (password)"
    echo "  - 'CloudFlare Account' (item with 'Account ID' custom field)"
    echo "  - 'GitHub Personal Access Token' (password)"
    echo "  - 'CloudCurio Database URL' (password)"
    echo "  - 'CloudCurio NextAuth Secret' (password)"
    echo "  - 'CloudCurio GitHub OAuth' (item with 'Client ID' field and password)"
    echo "  - 'CloudCurio Stripe Secret' (password)"
    echo "  - 'CloudCurio Stripe Product' (item with 'Price ID' custom field)"
    echo "  - 'CloudCurio Stripe Webhook' (password)"
    echo "  - 'CloudCurio Worker Token' (password)"
    echo "  - 'CloudCurio GitHub Webhook' (password)"
    echo "  - 'CloudCurio GitLab Webhook' (password)"
}

# Main function
main() {
    # Parse command line arguments
    SAVE_LOCAL=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --save-local)
                SAVE_LOCAL=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check if logged in to Bitwarden
    check_bw_login
    
    # Extract secrets
    extract_secrets
    
    # Save to local file if requested
    if [ "$SAVE_LOCAL" = true ]; then
        save_local_secrets
    fi
    
    echo ""
    echo "Secret extraction complete!"
    echo "Secrets are available as environment variables."
    if [ "$SAVE_LOCAL" = true ]; then
        echo "Secrets have also been saved to ~/.config/cloudcurio/secrets.env"
    fi
}

# Run main function
main "$@"