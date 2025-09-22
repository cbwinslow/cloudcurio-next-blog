#!/bin/bash
# Script to generate and store all required CloudCurio secrets in Bitwarden programmatically

set -e

# Function to check if required tools are available
check_requirements() {
    if ! command -v bw &> /dev/null; then
        echo "Error: Bitwarden CLI (bw) is not installed."
        echo "Please install it from https://bitwarden.com/help/cli/"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed."
        echo "Please install it with: sudo apt-get install jq (Ubuntu/Debian) or brew install jq (macOS)"
        exit 1
    fi
}

# Function to check if logged in with API key
check_api_login() {
    # Check if BW_CLIENTID and BW_CLIENTSECRET are set
    if [ -z "$BW_CLIENTID" ] || [ -z "$BW_CLIENTSECRET" ]; then
        echo "Error: BW_CLIENTID and BW_CLIENTSECRET environment variables must be set for API key authentication."
        echo "You can get these from your Bitwarden account settings:"
        echo "  1. Go to Bitwarden web app"
        echo "  2. Settings → Security → Keys"
        echo "  3. View API Key and copy the values"
        echo ""
        echo "Example:"
        echo "  export BW_CLIENTID=user.clientId-value"
        echo "  export BW_CLIENTSECRET=clientSecret-value"
        exit 1
    fi
    
    # Try to login with API key
    echo "Logging in with API key..."
    bw login --apikey >/dev/null 2>&1 || {
        echo "Error: Failed to login with API key. Please check your BW_CLIENTID and BW_CLIENTSECRET values."
        exit 1
    }
    
    # Unlock the vault
    echo "Unlocking vault..."
    export BW_SESSION=$(bw unlock --raw)
    
    if [ -z "$BW_SESSION" ]; then
        echo "Error: Failed to unlock vault."
        exit 1
    fi
    
    echo "Successfully logged in and unlocked vault with API key"
}

# Function to generate a secure random string
generate_secret() {
    local length=${1:-32}
    # Use openssl if available, otherwise fallback to /dev/urandom
    if command -v openssl &> /dev/null; then
        openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
    else
        cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w $length | head -n 1
    fi
}

# Function to create or update a Bitwarden item
create_bitwarden_item() {
    local name="$1"
    local type="$2"
    local data="$3"
    
    echo "Creating/updating Bitwarden item: $name"
    
    # Try to find existing item
    local existing_item=$(bw list items --search "$name" --session "$BW_SESSION" 2>/dev/null | jq -r ".[0] | select(.name==\"$name\") | .id" 2>/dev/null || echo "")
    
    if [ -n "$existing_item" ]; then
        echo "  Item already exists with ID: $existing_item"
        echo "  Skipping creation to avoid duplicates (edit manually if needed)"
        return 0
    fi
    
    # Create new item
    echo "$data" | bw encode | bw create item --session "$BW_SESSION" >/dev/null 2>&1 || {
        echo "  Error: Failed to create item '$name'"
        return 1
    }
    
    echo "  Successfully created item '$name'"
}

# Function to create all required CloudCurio secrets
create_cloudcurio_secrets() {
    echo "Generating and storing CloudCurio secrets in Bitwarden..."
    
    # 1. CloudFlare API Token
    local cloudflare_api_token=$(generate_secret 40)
    local cloudflare_item=$(bw get template item | jq --arg token "$cloudflare_api_token" --arg name "CloudFlare API Token" '
        .name=$name | 
        .type=1 | 
        .login.password=$token |
        .notes="CloudFlare API token for CloudCurio deployment"
    ')
    create_bitwarden_item "CloudFlare API Token" "login" "$cloudflare_item"
    
    # 2. CloudFlare Account (with custom field for Account ID)
    local cloudflare_account_id="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # This would typically be retrieved from CloudFlare
    local cloudflare_account_item=$(bw get template item | jq --arg account_id "$cloudflare_account_id" --arg name "CloudFlare Account" '
        .name=$name | 
        .type=1 | 
        .fields=[{"name":"Account ID","value":$account_id,"type":0}] |
        .notes="CloudFlare Account information for CloudCurio deployment"
    ')
    create_bitwarden_item "CloudFlare Account" "login" "$cloudflare_account_item"
    
    # 3. GitHub Personal Access Token
    local github_token=$(generate_secret 40)
    local github_item=$(bw get template item | jq --arg token "$github_token" --arg name "GitHub Personal Access Token" '
        .name=$name | 
        .type=1 | 
        .login.password=$token |
        .notes="GitHub Personal Access Token for CloudCurio deployment workflows"
    ')
    create_bitwarden_item "GitHub Personal Access Token" "login" "$github_item"
    
    # 4. Database URL
    local db_url="postgresql://user:$(generate_secret 20)@localhost:5432/cloudcurio"
    local db_item=$(bw get template item | jq --arg url "$db_url" --arg name "CloudCurio Database URL" '
        .name=$name | 
        .type=1 | 
        .login.password=$url |
        .notes="Database connection string for CloudCurio application"
    ')
    create_bitwarden_item "CloudCurio Database URL" "login" "$db_item"
    
    # 5. NextAuth Secret
    local nextauth_secret=$(generate_secret 32)
    local nextauth_item=$(bw get template item | jq --arg secret "$nextauth_secret" --arg name "CloudCurio NextAuth Secret" '
        .name=$name | 
        .type=1 | 
        .login.password=$secret |
        .notes="NextAuth secret for CloudCurio authentication"
    ')
    create_bitwarden_item "CloudCurio NextAuth Secret" "login" "$nextauth_item"
    
    # 6. GitHub OAuth (with Client ID field)
    local github_client_id="github_client_$(generate_secret 10)"
    local github_client_secret=$(generate_secret 40)
    local github_oauth_item=$(bw get template item | jq --arg client_id "$github_client_id" --arg client_secret "$github_client_secret" --arg name "CloudCurio GitHub OAuth" '
        .name=$name | 
        .type=1 | 
        .login.password=$client_secret |
        .fields=[{"name":"Client ID","value":$client_id,"type":0}] |
        .notes="GitHub OAuth credentials for CloudCurio authentication"
    ')
    create_bitwarden_item "CloudCurio GitHub OAuth" "login" "$github_oauth_item"
    
    # 7. Stripe Secret Key
    local stripe_secret="sk_test_$(generate_secret 24)"
    local stripe_item=$(bw get template item | jq --arg secret "$stripe_secret" --arg name "CloudCurio Stripe Secret" '
        .name=$name | 
        .type=1 | 
        .login.password=$secret |
        .notes="Stripe secret key for CloudCurio payment processing"
    ')
    create_bitwarden_item "CloudCurio Stripe Secret" "login" "$stripe_item"
    
    # 8. Stripe Product (with Price ID field)
    local stripe_price_id="price_$(generate_secret 14 | tr -d -_)"
    local stripe_product_item=$(bw get template item | jq --arg price_id "$stripe_price_id" --arg name "CloudCurio Stripe Product" '
        .name=$name | 
        .type=1 | 
        .fields=[{"name":"Price ID","value":$price_id,"type":0}] |
        .notes="Stripe product information for CloudCurio"
    ')
    create_bitwarden_item "CloudCurio Stripe Product" "login" "$stripe_product_item"
    
    # 9. Stripe Webhook Secret
    local stripe_webhook_secret=$(generate_secret 32)
    local stripe_webhook_item=$(bw get template item | jq --arg secret "$stripe_webhook_secret" --arg name "CloudCurio Stripe Webhook" '
        .name=$name | 
        .type=1 | 
        .login.password=$secret |
        .notes="Stripe webhook secret for CloudCurio payment processing"
    ')
    create_bitwarden_item "CloudCurio Stripe Webhook" "login" "$stripe_webhook_item"
    
    # 10. Worker Token
    local worker_token=$(generate_secret 32)
    local worker_item=$(bw get template item | jq --arg token "$worker_token" --arg name "CloudCurio Worker Token" '
        .name=$name | 
        .type=1 | 
        .login.password=$token |
        .notes="Authentication token for CloudCurio worker processes"
    ')
    create_bitwarden_item "CloudCurio Worker Token" "login" "$worker_item"
    
    # 11. GitHub Webhook Secret
    local github_webhook_secret=$(generate_secret 32)
    local github_webhook_item=$(bw get template item | jq --arg secret "$github_webhook_secret" --arg name "CloudCurio GitHub Webhook" '
        .name=$name | 
        .type=1 | 
        .login.password=$secret |
        .notes="Secret for GitHub webhook verification in CloudCurio"
    ')
    create_bitwarden_item "CloudCurio GitHub Webhook" "login" "$github_webhook_item"
    
    # 12. GitLab Webhook Token
    local gitlab_webhook_token=$(generate_secret 32)
    local gitlab_webhook_item=$(bw get template item | jq --arg token "$gitlab_webhook_token" --arg name "CloudCurio GitLab Webhook" '
        .name=$name | 
        .type=1 | 
        .login.password=$token |
        .notes="Token for GitLab webhook verification in CloudCurio"
    ')
    create_bitwarden_item "CloudCurio GitLab Webhook" "login" "$gitlab_webhook_item"
    
    echo "All CloudCurio secrets have been generated and stored in Bitwarden!"
}

# Function to display usage instructions
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Generate and store all required CloudCurio secrets in Bitwarden programmatically."
    echo ""
    echo "Requirements:"
    echo "  - Bitwarden CLI (bw) must be installed"
    echo "  - jq must be installed"
    echo "  - BW_CLIENTID and BW_CLIENTSECRET environment variables must be set"
    echo ""
    echo "Environment Variables:"
    echo "  BW_CLIENTID      Bitwarden API client ID"
    echo "  BW_CLIENTSECRET  Bitwarden API client secret"
    echo ""
    echo "Example:"
    echo "  export BW_CLIENTID=user.clientId-value"
    echo "  export BW_CLIENTSECRET=clientSecret-value"
    echo "  $0"
    echo ""
    echo "Note: This script will generate new secure secrets and store them in your Bitwarden vault."
    echo "Existing items with the same names will be skipped to avoid duplicates."
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
    
    # Check API login
    check_api_login
    
    # Create CloudCurio secrets
    create_cloudcurio_secrets
    
    # Sync to ensure changes are saved
    echo "Syncing with Bitwarden server..."
    bw sync --session "$BW_SESSION" >/dev/null 2>&1
    
    echo ""
    echo "Setup complete! All CloudCurio secrets have been generated and stored in Bitwarden."
    echo "You can now use the Bitwarden extraction script to retrieve them:"
    echo "  ./scripts/extract-bitwarden-secrets.sh --save-local"
}

# Run main function
main "$@"