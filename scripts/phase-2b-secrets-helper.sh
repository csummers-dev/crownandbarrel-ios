#!/bin/bash

# Crown & Barrel - Phase 2B GitHub Secrets Helper Script
# Assists with preparing certificates and profiles for GitHub Secrets

set -euo pipefail

echo "🔐 Crown & Barrel - Phase 2B GitHub Secrets Helper"
echo "================================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "This script helps you prepare certificates and provisioning profiles"
echo "for GitHub Secrets configuration."
echo ""

# Function to encode file to base64
encode_file() {
    local file_path="$1"
    local secret_name="$2"
    
    if [[ -f "$file_path" ]]; then
        print_status "Encoding $file_path for GitHub Secret: $secret_name"
        base64 -i "$file_path" | pbcopy
        print_success "Base64 encoded content copied to clipboard!"
        echo "📋 Ready to paste as GitHub Secret: $secret_name"
        echo ""
        read -p "Press Enter after you've pasted this secret in GitHub, then we'll continue..."
        echo ""
    else
        print_error "File not found: $file_path"
        echo "Please locate the correct file path and try again."
        return 1
    fi
}

echo "📋 GitHub Secrets Configuration Guide"
echo "====================================="
echo ""
echo "We need to configure 4 required GitHub Secrets:"
echo "1. APPLE_TEAM_ID (your Team ID from Phase 2A)"
echo "2. APPLE_CERTIFICATE_P12 (base64 encoded distribution certificate)"
echo "3. APPLE_CERTIFICATE_PASSWORD (password for the .p12 file)"
echo "4. APPLE_PROVISIONING_PROFILE (base64 encoded provisioning profile)"
echo ""
echo "🔗 GitHub Secrets Location:"
echo "https://github.com/csummers-dev/crownandbarrel-ios/settings/secrets/actions"
echo ""

# Step 1: Team ID
echo "📝 Step 1: APPLE_TEAM_ID"
echo "======================="
read -p "Enter your Team ID from Phase 2A (10 characters): " TEAM_ID

if [[ ${#TEAM_ID} -eq 10 ]]; then
    print_success "Team ID format correct: $TEAM_ID"
    echo "📋 Copy this value for GitHub Secret APPLE_TEAM_ID: $TEAM_ID"
    echo "$TEAM_ID" | pbcopy
    print_success "Team ID copied to clipboard!"
    echo ""
    read -p "Press Enter after you've added APPLE_TEAM_ID secret in GitHub..."
    echo ""
else
    print_warning "Team ID should be exactly 10 characters. Please double-check."
    echo "Example format: ABCD123456"
fi

# Step 2: Distribution Certificate
echo "📝 Step 2: APPLE_CERTIFICATE_P12"
echo "================================"
echo ""
print_status "You need to export your distribution certificate as .p12 file"
echo ""
echo "Steps to export certificate:"
echo "1. Open Keychain Access"
echo "2. Select 'My Certificates' category"
echo "3. Find 'iPhone Distribution: [Your Name]'"
echo "4. Right-click → Export 'iPhone Distribution: [Your Name]'"
echo "5. Save as: CrownBarrel_Distribution.p12"
echo "6. Set a secure password (you'll need this for the next secret)"
echo "7. Save to Desktop or Documents"
echo ""

read -p "Enter the path to your exported .p12 file: " P12_PATH

# Handle relative paths and common locations
if [[ "$P12_PATH" =~ ^~ ]]; then
    P12_PATH="${P12_PATH/#\~/$HOME}"
elif [[ ! "$P12_PATH" =~ ^/ ]]; then
    # Relative path, try common locations
    if [[ -f "$HOME/Desktop/$P12_PATH" ]]; then
        P12_PATH="$HOME/Desktop/$P12_PATH"
    elif [[ -f "$HOME/Documents/$P12_PATH" ]]; then
        P12_PATH="$HOME/Documents/$P12_PATH"
    elif [[ -f "$HOME/Downloads/$P12_PATH" ]]; then
        P12_PATH="$HOME/Downloads/$P12_PATH"
    fi
fi

encode_file "$P12_PATH" "APPLE_CERTIFICATE_P12"

# Step 3: Certificate Password
echo "📝 Step 3: APPLE_CERTIFICATE_PASSWORD"
echo "====================================="
echo ""
read -s -p "Enter the password you used for the .p12 file: " CERT_PASSWORD
echo ""
echo "$CERT_PASSWORD" | pbcopy
print_success "Certificate password copied to clipboard!"
echo "📋 Paste this as GitHub Secret: APPLE_CERTIFICATE_PASSWORD"
echo ""
read -p "Press Enter after you've added APPLE_CERTIFICATE_PASSWORD secret in GitHub..."
echo ""

# Step 4: Provisioning Profile
echo "📝 Step 4: APPLE_PROVISIONING_PROFILE"
echo "====================================="
echo ""
print_status "You need to locate your downloaded provisioning profile"
echo ""
echo "Common locations for .mobileprovision files:"
echo "• ~/Downloads/Crown_Barrel_App_Store_Distribution.mobileprovision"
echo "• ~/Library/MobileDevice/Provisioning Profiles/"
echo "• Desktop (if you saved it there)"
echo ""

read -p "Enter the path to your .mobileprovision file: " PROFILE_PATH

# Handle relative paths and common locations
if [[ "$PROFILE_PATH" =~ ^~ ]]; then
    PROFILE_PATH="${PROFILE_PATH/#\~/$HOME}"
elif [[ ! "$PROFILE_PATH" =~ ^/ ]]; then
    # Relative path, try common locations
    if [[ -f "$HOME/Downloads/$PROFILE_PATH" ]]; then
        PROFILE_PATH="$HOME/Downloads/$PROFILE_PATH"
    elif [[ -f "$HOME/Desktop/$PROFILE_PATH" ]]; then
        PROFILE_PATH="$HOME/Desktop/$PROFILE_PATH"
    fi
fi

encode_file "$PROFILE_PATH" "APPLE_PROVISIONING_PROFILE"

# Summary
echo "🎉 GitHub Secrets Configuration Complete!"
echo "========================================"
echo ""
echo "Configured Secrets:"
echo "✅ APPLE_TEAM_ID: $TEAM_ID"
echo "✅ APPLE_CERTIFICATE_P12: [Base64 encoded]"
echo "✅ APPLE_CERTIFICATE_PASSWORD: [Secure password]"
echo "✅ APPLE_PROVISIONING_PROFILE: [Base64 encoded]"
echo ""
echo "Optional Secrets for Automated Upload:"
echo "❓ APPLE_ID: Your Apple ID email"
echo "❓ APPLE_APP_SPECIFIC_PASSWORD: App-specific password for altool"
echo ""
print_success "Phase 2B GitHub Secrets configuration ready!"
echo ""
echo "🚀 Next Steps:"
echo "1. Test the updated release workflow"
echo "2. Validate automated code signing in GitHub Actions"
echo "3. Proceed to Phase 3: App Store Connect Configuration"
