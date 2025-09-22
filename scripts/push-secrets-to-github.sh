#!/bin/bash
# Script to push local secrets to GitHub repository

set -e

# Function to check if required tools are available
check_requirements() {
    if ! command -v python3 &> /dev/null; then
        echo "Error: Python 3 is required but not installed."
        exit 1
    fi
    
    if ! command -v pip &> /dev/null; then
        echo "Error: pip is required but not installed."
        exit 1
    fi
    
    # Check if GitHub CLI is available (optional but useful)
    if command -v gh &> /dev/null; then
        echo "GitHub CLI found"
    else
        echo "GitHub CLI not found (optional, but recommended for some operations)"
    fi
}

# Function to load local secrets
load_local_secrets() {
    SECRETS_DIR="$HOME/.config/cloudcurio"
    SECRETS_FILE="$SECRETS_DIR/secrets.env"
    
    # Check if secrets file exists
    if [ ! -f "$SECRETS_FILE" ]; then
        echo "Error: Secrets file not found at $SECRETS_FILE"
        echo "Please run the local secrets setup first:"
        echo "  ./scripts/setup-local-secrets.sh --all"
        echo "Then add your secrets with:"
        echo "  $SECRETS_DIR/edit-secrets.sh"
        echo "Finally load them with:"
        echo "  source $SECRETS_DIR/load-secrets.sh"
        exit 1
    fi
    
    # Source the secrets file
    set -a  # Automatically export all variables
    source "$SECRETS_FILE"
    set +a
    
    echo "Local secrets loaded"
}

# Function to validate required secrets
validate_secrets() {
    echo "Validating required secrets..."
    
    local missing_secrets=()
    
    # Check CloudFlare secrets
    if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
        missing_secrets+=("CLOUDFLARE_API_TOKEN")
    fi
    
    if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
        missing_secrets+=("CLOUDFLARE_ACCOUNT_ID")
    fi
    
    # Check GitHub token
    if [ -z "$GITHUB_TOKEN" ]; then
        missing_secrets+=("GITHUB_TOKEN")
    fi
    
    # Report missing secrets
    if [ ${#missing_secrets[@]} -gt 0 ]; then
        echo "Error: Missing required secrets:"
        for secret in "${missing_secrets[@]}"; do
            echo "  - $secret"
        done
        echo "Please add these secrets to $HOME/.config/cloudcurio/secrets.env"
        exit 1
    fi
    
    echo "All required secrets present"
}

# Function to push secrets to GitHub using our existing script
push_secrets_to_github() {
    echo "Pushing secrets to GitHub..."
    
    # Check if our GitHub secret script exists
    if [ ! -f "scripts/add-github-secret.py" ]; then
        echo "Error: GitHub secret management script not found"
        echo "Please run this script from the repository root"
        exit 1
    fi
    
    # Install required Python packages
    echo "Installing required Python packages..."
    pip install requests pynacl >/dev/null 2>&1
    
    # Repository information
    REPO_OWNER="cbwinslow"
    REPO_NAME="cloudcurio-next-blog"
    
    # Add CloudFlare API token
    if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
        echo "Adding CLOUDFLARE_API_TOKEN to GitHub secrets..."
        python3 scripts/add-github-secret.py \
            --owner "$REPO_OWNER" \
            --repo "$REPO_NAME" \
            --token "$GITHUB_TOKEN" \
            --secret-name "CLOUDFLARE_API_TOKEN" \
            --secret-value "$CLOUDFLARE_API_TOKEN"
    fi
    
    # Add CloudFlare Account ID
    if [ -n "$CLOUDFLARE_ACCOUNT_ID" ]; then
        echo "Adding CLOUDFLARE_ACCOUNT_ID to GitHub secrets..."
        python3 scripts/add-github-secret.py \
            --owner "$REPO_OWNER" \
            --repo "$REPO_NAME" \
            --token "$GITHUB_TOKEN" \
            --secret-name "CLOUDFLARE_ACCOUNT_ID" \
            --secret-value "$CLOUDFLARE_ACCOUNT_ID"
    fi
    
    echo "Secrets successfully pushed to GitHub!"
}

# Function to display usage instructions
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Push local secrets to GitHub repository."
    echo ""
    echo "Requirements:"
    echo "  - Python 3 and pip must be installed"
    echo "  - Local secrets must be set up and loaded"
    echo "  - GitHub personal access token with repo scope"
    echo ""
    echo "Options:"
    echo "  --help          Show this help message"
    echo ""
    echo "Before running this script:"
    echo "  1. Set up local secrets: ./scripts/setup-local-secrets.sh --all"
    echo "  2. Add your secrets: ~/.config/cloudcurio/edit-secrets.sh"
    echo "  3. Load secrets: source ~/.config/cloudcurio/load-secrets.sh"
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
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
    
    # Check requirements
    check_requirements
    
    # Load local secrets
    load_local_secrets
    
    # Validate secrets
    validate_secrets
    
    # Push secrets to GitHub
    push_secrets_to_github
    
    echo ""
    echo "GitHub secrets setup complete!"
    echo "Your CloudFlare deployment should now work automatically."
}

# Run main function
main "$@"