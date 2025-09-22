#!/bin/bash
# Script to set up local secret management for CloudCurio using bash secrets

set -e

# Function to create a secure directory for secrets
setup_secrets_directory() {
    SECRETS_DIR="$HOME/.config/cloudcurio"
    echo "Creating secure directory for secrets at $SECRETS_DIR"
    
    # Create directory if it doesn't exist
    mkdir -p "$SECRETS_DIR"
    
    # Set secure permissions
    chmod 700 "$SECRETS_DIR"
    
    echo "Secrets directory created with secure permissions (700)"
}

# Function to create a template for local secrets
create_secrets_template() {
    SECRETS_DIR="$HOME/.config/cloudcurio"
    TEMPLATE_FILE="$SECRETS_DIR/secrets.template"
    
    echo "Creating secrets template at $TEMPLATE_FILE"
    
    cat > "$TEMPLATE_FILE" << 'EOF'
# CloudCurio Local Secrets Template
# Copy this file to secrets.env and fill in your actual secrets
# Then source it with: source ~/.config/cloudcurio/secrets.env

# CloudFlare Deployment
CLOUDFLARE_API_TOKEN=your_cloudflare_api_token_here
CLOUDFLARE_ACCOUNT_ID=your_cloudflare_account_id_here

# GitHub (for GitHub Actions deployment)
GITHUB_TOKEN=your_github_personal_access_token_here

# Database
DATABASE_URL=your_database_connection_string_here

# Authentication
NEXTAUTH_SECRET=your_nextauth_secret_here
GITHUB_ID=your_github_oauth_client_id_here
GITHUB_SECRET=your_github_oauth_client_secret_here

# Stripe
STRIPE_SECRET_KEY=your_stripe_secret_key_here
STRIPE_PRICE_PRO=your_stripe_price_id_here
STRIPE_WEBHOOK_SECRET=your_stripe_webhook_secret_here

# Worker
WORKER_TOKEN=your_worker_authentication_token_here

# Webhooks
GITHUB_WEBHOOK_SECRET=your_github_webhook_secret_here
GITLAB_WEBHOOK_TOKEN=your_gitlab_webhook_token_here
EOF
    
    echo "Secrets template created"
    echo "To use it, copy it to secrets.env and fill in your actual values:"
    echo "  cp $TEMPLATE_FILE $SECRETS_DIR/secrets.env"
    echo "  # Edit $SECRETS_DIR/secrets.env with your actual secrets"
}

# Function to create a script for loading secrets
create_load_script() {
    SECRETS_DIR="$HOME/.config/cloudcurio"
    LOAD_SCRIPT="$SECRETS_DIR/load-secrets.sh"
    
    echo "Creating script to load secrets at $LOAD_SCRIPT"
    
    cat > "$LOAD_SCRIPT" << 'EOF'
#!/bin/bash
# Script to load CloudCurio secrets into environment variables

SECRETS_DIR="$HOME/.config/cloudcurio"
SECRETS_FILE="$SECRETS_DIR/secrets.env"

# Check if secrets file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "Error: Secrets file not found at $SECRETS_FILE"
    echo "Please create it by copying $SECRETS_DIR/secrets.template to $SECRETS_FILE"
    echo "and filling in your actual secrets."
    exit 1
fi

# Check file permissions (should be owner read/write only)
PERMISSIONS=$(stat -c "%a" "$SECRETS_FILE" 2>/dev/null || stat -f "%OLp" "$SECRETS_FILE" 2>/dev/null)
if [ "$PERMISSIONS" != "600" ]; then
    echo "Warning: Secrets file permissions are $PERMISSIONS, recommended is 600 (owner read/write only)"
    echo "You can fix this with: chmod 600 $SECRETS_FILE"
fi

# Source the secrets file
set -a  # Automatically export all variables
source "$SECRETS_FILE"
set +a

echo "CloudCurio secrets loaded into environment variables"
EOF
    
    # Make the load script executable
    chmod +x "$LOAD_SCRIPT"
    
    echo "Secret loading script created"
    echo "To load secrets, run: source $LOAD_SCRIPT"
}

# Function to create a script for securely editing secrets
create_edit_script() {
    SECRETS_DIR="$HOME/.config/cloudcurio"
    EDIT_SCRIPT="$SECRETS_DIR/edit-secrets.sh"
    
    echo "Creating script to securely edit secrets at $EDIT_SCRIPT"
    
    cat > "$EDIT_SCRIPT" << 'EOF'
#!/bin/bash
# Script to securely edit CloudCurio secrets

SECRETS_DIR="$HOME/.config/cloudcurio"
SECRETS_FILE="$SECRETS_DIR/secrets.env"
TEMPLATE_FILE="$SECRETS_DIR/secrets.template"

# Check if secrets file exists, if not create from template
if [ ! -f "$SECRETS_FILE" ]; then
    if [ -f "$TEMPLATE_FILE" ]; then
        echo "Creating secrets file from template..."
        cp "$TEMPLATE_FILE" "$SECRETS_FILE"
        chmod 600 "$SECRETS_FILE"
    else
        echo "Error: Neither secrets file nor template found"
        exit 1
    fi
fi

# Check file permissions and fix if needed
PERMISSIONS=$(stat -c "%a" "$SECRETS_FILE" 2>/dev/null || stat -f "%OLp" "$SECRETS_FILE" 2>/dev/null)
if [ "$PERMISSIONS" != "600" ]; then
    echo "Fixing secrets file permissions to 600..."
    chmod 600 "$SECRETS_FILE"
fi

# Use the default editor or nano/vi if not set
EDITOR=${EDITOR:-$(which nano || which vi || echo "vi")}

# Edit the secrets file
echo "Opening $SECRETS_FILE for editing..."
$EDITOR "$SECRETS_FILE"

echo "Secrets file updated"
EOF
    
    # Make the edit script executable
    chmod +x "$EDIT_SCRIPT"
    
    echo "Secret editing script created"
    echo "To edit secrets, run: $EDIT_SCRIPT"
}

# Function to display usage instructions
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Set up local secret management for CloudCurio using bash secrets."
    echo ""
    echo "Options:"
    echo "  --all           Set up all components (directory, template, load script, edit script)"
    echo "  --directory     Create secure directory for secrets"
    echo "  --template      Create secrets template file"
    echo "  --load-script   Create script to load secrets into environment"
    echo "  --edit-script   Create script to securely edit secrets"
    echo "  --help          Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --all        # Set up complete local secret management"
    echo ""
    echo "After setup:"
    echo "  1. Edit secrets: $HOME/.config/cloudcurio/edit-secrets.sh"
    echo "  2. Load secrets: source $HOME/.config/cloudcurio/load-secrets.sh"
}

# Main function
main() {
    # Parse command line arguments
    if [ $# -eq 0 ]; then
        echo "No options specified. Use --help for usage information."
        exit 1
    fi
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                setup_secrets_directory
                create_secrets_template
                create_load_script
                create_edit_script
                echo ""
                echo "Complete local secret management setup finished!"
                echo "Run $HOME/.config/cloudcurio/edit-secrets.sh to add your secrets"
                echo "Run 'source $HOME/.config/cloudcurio/load-secrets.sh' to load secrets"
                shift
                ;;
            --directory)
                setup_secrets_directory
                shift
                ;;
            --template)
                create_secrets_template
                shift
                ;;
            --load-script)
                create_load_script
                shift
                ;;
            --edit-script)
                create_edit_script
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
}

# Run main function
main "$@"