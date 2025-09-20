#!/bin/bash
set -euo pipefail

# Ensure we're using bash
if [ -z "$BASH_VERSION" ]; then
    echo "This script requires bash. Please run with: bash $0"
    exit 1
fi

# Crown & Barrel CI/CD Setup Script
# This script helps automate the setup of CI/CD variables and configurations

echo "🚀 Crown & Barrel CI/CD Setup Assistant"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to prompt for input with validation
prompt_with_validation() {
    local prompt="$1"
    local var_name="$2"
    local validation_func="$3"
    
    while true; do
        read -p "$prompt: " input
        if eval "$validation_func \"$input\""; then
            eval "$var_name='$input'"
            break
        else
            echo -e "${RED}Invalid input. Please try again.${NC}"
        fi
    done
}

# Validation functions
validate_email() {
    echo "$1" | grep -E '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > /dev/null
}

validate_team_id() {
    echo "$1" | grep -E '^[A-Z0-9]{10}$' > /dev/null
}

validate_bundle_id() {
    echo "$1" | grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+$' > /dev/null
}

echo -e "${BLUE}This script will help you configure your GitLab CI/CD pipeline.${NC}"
echo ""

# Get GitLab project information
echo -e "${YELLOW}📋 GitLab Project Information${NC}"
echo "Enter your GitLab project URL (e.g., https://gitlab.com/username/crown-and-barrel)"
read -p "GitLab Project URL: " GITLAB_PROJECT_URL

if [ -z "$GITLAB_PROJECT_URL" ]; then
    echo -e "${RED}GitLab project URL is required.${NC}"
    exit 1
fi

# Extract project path from URL
PROJECT_PATH=$(echo "$GITLAB_PROJECT_URL" | sed 's|https://gitlab.com/||' | sed 's|\.git$||')
echo "Project path: $PROJECT_PATH"

echo ""
echo -e "${YELLOW}🍎 Apple Developer Account Information${NC}"
echo "You'll need to set up these variables in GitLab CI/CD Settings → Variables:"
echo ""
echo -e "${BLUE}📝 Important: App-Specific Password${NC}"
echo "You need to create an App-Specific Password for GitLab CI/CD:"
echo "1. Go to https://appleid.apple.com"
echo "2. Sign in with your Apple ID"
echo "3. Go to 'Sign-In and Security' → 'App-Specific Passwords'"
echo "4. Click 'Generate an app-specific password'"
echo "5. Label it 'GitLab CI/CD - Crown & Barrel'"
echo "6. Copy the generated password (format: abcd-efgh-ijkl-mnop)"
echo ""

# Apple Developer credentials
echo "Enter your Apple ID email address:"
read -p "Apple ID (email): " APPLE_ID
while ! validate_email "$APPLE_ID"; do
    echo -e "${RED}Invalid email format. Please try again.${NC}"
    read -p "Apple ID (email): " APPLE_ID
done

echo ""
echo -e "${YELLOW}Enter the App-Specific Password you just created (not your regular Apple ID password):${NC}"
read -p "App-specific password: " APPLE_PASSWORD
while [ -z "$APPLE_PASSWORD" ]; do
    echo -e "${RED}App-specific password is required. Please try again.${NC}"
    read -p "App-specific password: " APPLE_PASSWORD
done

echo "Enter your Apple Developer Team ID (10 characters):"
read -p "Team ID: " TEAM_ID
while ! validate_team_id "$TEAM_ID"; do
    echo -e "${RED}Invalid Team ID format. Should be 10 characters (e.g., ABC123DEFG). Please try again.${NC}"
    read -p "Team ID: " TEAM_ID
done

echo "Enter your app's Bundle ID:"
read -p "Bundle ID: " BUNDLE_ID
while ! validate_bundle_id "$BUNDLE_ID"; do
    echo -e "${RED}Invalid Bundle ID format. Should be like com.company.app. Please try again.${NC}"
    read -p "Bundle ID: " BUNDLE_ID
done

echo ""
echo -e "${YELLOW}📱 App Information${NC}"
read -p "App Name (default: Crown & Barrel): " APP_NAME
APP_NAME=${APP_NAME:-"Crown & Barrel"}

echo ""
echo -e "${YELLOW}🔐 Security Setup${NC}"
echo "Generating secure random values for additional security..."

# Generate random values
MATCH_PASSWORD=$(openssl rand -base64 32)
FASTLANE_SESSION=$(openssl rand -base64 64)

echo ""
echo -e "${GREEN}✅ Configuration Summary${NC}"
echo "=========================="
echo "GitLab Project: $PROJECT_PATH"
echo "Apple ID: $APPLE_ID"
echo "Team ID: $TEAM_ID"
echo "Bundle ID: $BUNDLE_ID"
echo "App Name: $APP_NAME"
echo ""

# Create GitLab CI/CD variables configuration
cat > gitlab-ci-variables.md << EOF
# GitLab CI/CD Variables Configuration

Add these variables to your GitLab project:
**Settings → CI/CD → Variables**

## Required Variables

| Variable | Value | Type | Protected | Masked |
|----------|-------|------|-----------|--------|
| \`APPLE_ID\` | \`$APPLE_ID\` | Variable | ✅ | ❌ |
| \`APPLE_ID_PASSWORD\` | \`$APPLE_PASSWORD\` | Variable | ✅ | ✅ |
| \`FASTLANE_USER\` | \`$APPLE_ID\` | Variable | ✅ | ❌ |
| \`FASTLANE_PASSWORD\` | \`$APPLE_PASSWORD\` | Variable | ✅ | ✅ |
| \`FASTLANE_SESSION\` | \`$FASTLANE_SESSION\` | Variable | ✅ | ✅ |
| \`MATCH_PASSWORD\` | \`$MATCH_PASSWORD\` | Variable | ✅ | ✅ |
| \`TEAM_ID\` | \`$TEAM_ID\` | Variable | ✅ | ❌ |
| \`BUNDLE_ID\` | \`$BUNDLE_ID\` | Variable | ❌ | ❌ |

## Optional Variables

| Variable | Value | Type | Protected | Masked |
|----------|-------|------|-----------|--------|
| \`IOS_SIMULATOR_NAME\` | \`iPhone 16\` | Variable | ❌ | ❌ |
| \`BUILD_CONFIGURATION\` | \`Release\` | Variable | ❌ | ❌ |

## File Variables (for certificates)

| Variable | File Path | Type | Protected | Masked |
|----------|-----------|------|-----------|--------|
| \`CERTIFICATE_P12\` | \`path/to/certificate.p12\` | File | ✅ | ❌ |
| \`CERTIFICATE_PASSWORD\` | \`certificate-password\` | Variable | ✅ | ✅ |

EOF

# Update exportOptions.plist
echo "Updating exportOptions.plist..."
sed -i.bak "s/YOUR_TEAM_ID/$TEAM_ID/g" exportOptions.plist
sed -i.bak "s/YOUR_PROVISIONING_PROFILE_NAME/$BUNDLE_ID Development/g" exportOptions.plist
rm -f exportOptions.plist.bak

# Create Fastlane configuration
mkdir -p fastlane
cat > fastlane/Fastfile << EOF
# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
#     https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
#     https://docs.fastlane.tools/plugins/available-plugins
#

# Uncomment the line if you want fastlane to automatically update itself
# update_fastlane

default_platform(:ios)

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    increment_build_number
    build_app(
      scheme: "CrownAndBarrel",
      export_method: "app-store"
    )
    upload_to_testflight
  end

  desc "Deploy to App Store"
  lane :release do
    increment_build_number
    build_app(
      scheme: "CrownAndBarrel",
      export_method: "app-store"
    )
    upload_to_app_store(
      force: true,
      skip_metadata: false,
      skip_screenshots: false
    )
  end
end
EOF

cat > fastlane/Appfile << EOF
# The Appfile is a configuration file for fastlane. It's usually placed in the root of the project.
# It contains metadata about your app that can be used by fastlane.
# If you want to get a list of all available options run \`fastlane docs\`

app_identifier("$BUNDLE_ID")
apple_id("$APPLE_ID")
team_id("$TEAM_ID")

# For more information about the Appfile, see:
#     https://docs.fastlane.tools/advanced/#appfile
EOF

echo ""
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "=========================="
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Add the variables from \`gitlab-ci-variables.md\` to your GitLab project"
echo "2. Commit and push these changes to trigger the pipeline"
echo "3. Check your GitLab CI/CD pipelines page to monitor progress"
echo ""
echo -e "${BLUE}Files Created/Updated:${NC}"
echo "✅ gitlab-ci-variables.md - Variable configuration guide"
echo "✅ exportOptions.plist - Updated with your Team ID"
echo "✅ fastlane/Fastfile - Fastlane configuration"
echo "✅ fastlane/Appfile - App configuration"
echo ""
echo -e "${YELLOW}📖 For detailed instructions, see CI_README.md${NC}"
