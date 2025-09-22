#!/bin/bash
# Fully automated CloudCurio secret management using Bitwarden API keys

set -e

# Function to check if required tools are available
check_requirements() {
    local missing_tools=()
    
    if ! command -v bw &> /dev/null; then
        missing_tools+=("Bitwarden CLI (bw)")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_tools+=("Python 3")
    fi
    
    if ! command -v pip &> /dev/null; then
        missing_tools+=("pip")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "Error: Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo "Please install the missing tools:"
        echo "  Bitwarden CLI: https://bitwarden.com/help/cli/"
        echo "  jq: sudo apt-get install jq (Ubuntu/Debian) or brew install jq (macOS)"
        echo "  Python 3 and pip: sudo apt-get install python3 python3-pip (Ubuntu/Debian)"
        exit 1
    fi
}

# Function to validate Bitwarden API credentials
validate_bitwarden_credentials() {
    if [ -z "$BW_CLIENTID" ] || [ -z "$BW_CLIENTSECRET" ]; then
        echo "Error: BW_CLIENTID and BW_CLIENTSECRET environment variables must be set."
        echo ""
        echo "To get your Bitwarden API credentials:"
        echo "  1. Go to the Bitwarden web app"
        echo "  2. Navigate to Settings → Security → Keys"
        echo "  3. Click 'View API Key'"
        echo "  4. Copy the Client ID and Client Secret"
        echo ""
        echo "Then set them as environment variables:"
        echo "  export BW_CLIENTID=user.clientId-value"
        echo "  export BW_CLIENTSECRET=clientSecret-value"
        exit 1
    fi
}

# Function to run the complete automated workflow
run_automated_workflow() {
    echo "=== CloudCurio Fully Automated Secret Management ==="
    echo ""
    
    # Step 1: Generate and store secrets in Bitwarden
    echo "Step 1: Generating and storing secrets in Bitwarden..."
    ./scripts/generate-bitwarden-secrets.sh
    
    # Step 2: Extract secrets from Bitwarden
    echo ""
    echo "Step 2: Extracting secrets from Bitwarden..."
    ./scripts/extract-bitwarden-secrets.sh --save-local
    
    # Step 3: Set up local secret management
    echo ""
    echo "Step 3: Setting up local secret management..."
    ./scripts/setup-local-secrets.sh --all
    
    # Step 4: Load secrets into environment
    echo ""
    echo "Step 4: Loading secrets into environment..."
    source ~/.config/cloudcurio/load-secrets.sh
    
    # Step 5: Push secrets to GitHub
    echo ""
    echo "Step 5: Pushing secrets to GitHub..."
    ./scripts/push-secrets-to-github.sh
    
    echo ""
    echo "=== Automated Setup Complete! ==="
    echo ""
    echo "Summary of what was accomplished:"
    echo "  ✓ Generated 12 secure secrets for CloudCurio"
    echo "  ✓ Stored all secrets in Bitwarden vault"
    echo "  ✓ Extracted secrets to local secure storage"
    echo "  ✓ Set up local secret management system"
    echo "  ✓ Pushed deployment secrets to GitHub"
    echo ""
    echo "Your CloudCurio deployment is now fully configured!"
    echo "The next push to the main branch will automatically deploy to CloudFlare."
}

# Function to display usage instructions
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Fully automated CloudCurio secret management using Bitwarden API keys."
    echo ""
    echo "This script performs the complete workflow:"
    echo "  1. Generates and stores all required secrets in Bitwarden"
    echo "  2. Extracts secrets from Bitwarden to local storage"
    echo "  3. Sets up local secret management"
    echo "  4. Loads secrets into the environment"
    echo "  5. Pushes deployment secrets to GitHub"
    echo ""
    echo "Requirements:"
    echo "  - Bitwarden CLI (bw), jq, Python 3, and pip must be installed"
    echo "  - BW_CLIENTID and BW_CLIENTSECRET environment variables must be set"
    echo ""
    echo "Environment Variables:"
    echo "  BW_CLIENTID      Bitwarden API client ID"
    echo "  BW_CLIENTSECRET  Bitwarden API client secret"
    echo "  GITHUB_TOKEN     GitHub personal access token (optional, will prompt if not set)"
    echo ""
    echo "Example:"
    echo "  export BW_CLIENTID=user.clientId-value"
    echo "  export BW_CLIENTSECRET=clientSecret-value"
    echo "  $0"
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
    
    # Validate Bitwarden credentials
    validate_bitwarden_credentials
    
    # Run the automated workflow
    run_automated_workflow
}

# Run main function
main "$@"