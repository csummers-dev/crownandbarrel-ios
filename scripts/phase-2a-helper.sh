#!/bin/bash

# Crown & Barrel - Phase 2A Helper Script
# Assists with code signing setup and validation

set -euo pipefail

echo "🚀 Crown & Barrel - Phase 2A Code Signing Helper"
echo "=============================================="
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Phase 2A.1: Apple Developer Account Verification Helper
echo "📋 Phase 2A.1: Apple Developer Account Verification"
echo "================================================="
echo ""
print_status "This step requires manual action in Apple Developer Portal"
echo ""
echo "🔗 Please open: https://developer.apple.com/account"
echo ""
echo "Manual steps to complete:"
echo "1. Log in with your Apple ID"
echo "2. Verify active Apple Developer Program membership"
echo "3. Locate your Team ID (10-character alphanumeric)"
echo "4. Note account type (Individual or Organization)"
echo ""
echo "Once you have your Team ID, we'll update the export options automatically."
echo ""
read -p "Press Enter when you have your Team ID ready, or type 'skip' to continue: " user_input

if [[ "$user_input" != "skip" ]]; then
    echo ""
    read -p "Enter your Team ID (10 characters): " TEAM_ID
    
    if [[ ${#TEAM_ID} -eq 10 ]]; then
        print_success "Team ID format looks correct: $TEAM_ID"
        
        # Update export options with real Team ID
        print_status "Updating export options with your Team ID..."
        
        # Update TestFlight export options
        sed -i '' "s/PLACEHOLDER_TEAM_ID/$TEAM_ID/g" exportOptions-testflight.plist
        print_success "Updated exportOptions-testflight.plist"
        
        # Update App Store export options
        sed -i '' "s/PLACEHOLDER_TEAM_ID/$TEAM_ID/g" exportOptions-appstore.plist
        print_success "Updated exportOptions-appstore.plist"
        
        # Update main export options
        sed -i '' "s/ABC123DEFG/$TEAM_ID/g" exportOptions.plist
        print_success "Updated exportOptions.plist"
        
        echo ""
        print_success "Team ID configuration complete!"
        
        # Store Team ID for later use
        echo "$TEAM_ID" > .team-id-temp
        
    else
        print_warning "Team ID should be exactly 10 characters. Please double-check."
        echo "Example format: ABCD123456"
    fi
else
    print_warning "Skipping Team ID update - you'll need to update export options manually"
fi

echo ""
echo "📋 Phase 2A.2: App ID Registration"
echo "================================="
echo ""
print_status "This step requires manual action in Apple Developer Portal"
echo ""
echo "🔗 Please open: https://developer.apple.com/account/resources/identifiers/list"
echo ""
echo "Manual steps to complete:"
echo "1. Check if 'com.crownandbarrel.app' already exists"
echo "2. If not, click '+' to create new App ID"
echo "3. Use Bundle ID: com.crownandbarrel.app (Explicit)"
echo "4. Description: Crown & Barrel - Luxury Watch Collection"
echo "5. Enable capabilities:"
echo "   ✅ Core Data (Required)"
echo "   ❓ Background Processing (Optional - future features)"
echo "   ❓ Push Notifications (Optional - future features)"
echo "   ❓ iCloud (Optional - future cloud backup)"
echo ""
read -p "Press Enter when App ID is registered: " 

print_success "App ID registration step completed"

echo ""
echo "📋 Phase 2A.3: Distribution Certificate"
echo "======================================"
echo ""
print_status "This step requires manual action in Apple Developer Portal"
echo ""
echo "🔗 Please open: https://developer.apple.com/account/resources/certificates/list"
echo ""
echo "Manual steps to complete:"
echo "1. Click '+' to create new certificate"
echo "2. Select 'iOS Distribution' certificate type"
echo "3. Create Certificate Signing Request (CSR):"
echo "   • Open Keychain Access"
echo "   • Keychain Access → Certificate Assistant → Request Certificate from CA"
echo "   • Email: Your Apple ID email"
echo "   • Common Name: Crown & Barrel Distribution"
echo "   • Save to disk"
echo "4. Upload CSR file to Apple Developer Portal"
echo "5. Download completed certificate"
echo "6. Double-click to install in Keychain"
echo ""
read -p "Press Enter when distribution certificate is installed: "

# Verify certificate installation
print_status "Checking for distribution certificate in Keychain..."

if security find-identity -v -p codesigning | grep -q "iPhone Distribution"; then
    print_success "iPhone Distribution certificate found in Keychain!"
    
    # Show available signing identities
    echo ""
    print_status "Available code signing identities:"
    security find-identity -v -p codesigning | grep "iPhone Distribution" || echo "None found"
else
    print_warning "iPhone Distribution certificate not found in Keychain"
    echo "Please verify the certificate was installed correctly"
fi

echo ""
echo "📋 Phase 2A.4: Provisioning Profile"
echo "==================================="
echo ""
print_status "This step requires manual action in Apple Developer Portal"
echo ""
echo "🔗 Please open: https://developer.apple.com/account/resources/profiles/list"
echo ""
echo "Manual steps to complete:"
echo "1. Click '+' to create new provisioning profile"
echo "2. Select 'App Store' distribution type"
echo "3. App ID: Select 'com.crownandbarrel.app'"
echo "4. Certificate: Select your iOS Distribution certificate"
echo "5. Profile Name: Crown & Barrel App Store Distribution"
echo "6. Download and double-click to install"
echo ""
read -p "Press Enter when provisioning profile is installed: "

print_success "Provisioning profile installation step completed"

echo ""
echo "🧪 Phase 2A Validation: Testing Local Build"
echo "==========================================="
echo ""

# Check if we have the Team ID
if [[ -f ".team-id-temp" ]]; then
    TEAM_ID=$(cat .team-id-temp)
    print_status "Using Team ID: $TEAM_ID"
    
    print_status "Testing local signed archive creation..."
    
    # Test archive creation
    if xcodebuild archive \
        -project "CrownAndBarrel.xcodeproj" \
        -scheme "CrownAndBarrel" \
        -configuration "Release" \
        -destination "generic/platform=iOS" \
        -archivePath "CrownAndBarrel-Phase2A-Test.xcarchive" \
        CODE_SIGNING_ALLOWED=YES \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        CODE_SIGN_IDENTITY="iPhone Distribution" \
        -quiet; then
        
        print_success "Signed archive created successfully!"
        
        # Test IPA export
        print_status "Testing IPA export with TestFlight options..."
        
        if xcodebuild -exportArchive \
            -archivePath "CrownAndBarrel-Phase2A-Test.xcarchive" \
            -exportPath "CrownAndBarrel-Phase2A-Test" \
            -exportOptionsPlist "exportOptions-testflight.plist" \
            -quiet; then
            
            print_success "TestFlight IPA exported successfully!"
            
            # Check IPA file
            if [[ -f "CrownAndBarrel-Phase2A-Test/CrownAndBarrel.ipa" ]]; then
                IPA_SIZE=$(ls -lh "CrownAndBarrel-Phase2A-Test/CrownAndBarrel.ipa" | awk '{print $5}')
                print_success "IPA file created: $IPA_SIZE"
                
                echo ""
                print_success "🎉 Phase 2A Validation Complete!"
                echo ""
                echo "✅ Signed archive creation: SUCCESS"
                echo "✅ TestFlight IPA export: SUCCESS"
                echo "✅ Export options configuration: SUCCESS"
                echo "✅ Code signing setup: SUCCESS"
                echo ""
                print_success "Ready for Phase 2B: Build Pipeline Configuration"
                
                # Cleanup test files
                rm -rf "CrownAndBarrel-Phase2A-Test.xcarchive"
                rm -rf "CrownAndBarrel-Phase2A-Test"
                print_status "Cleaned up test files"
                
            else
                print_error "IPA file not found after export"
            fi
        else
            print_error "IPA export failed - check export options configuration"
        fi
    else
        print_error "Archive creation failed - check code signing configuration"
        echo ""
        print_status "Common issues:"
        echo "• Distribution certificate not installed in Keychain"
        echo "• Provisioning profile not installed or incorrect"
        echo "• Team ID doesn't match Apple Developer account"
        echo "• Bundle ID mismatch between project and App ID"
    fi
    
    # Cleanup temp file
    rm -f ".team-id-temp"
    
else
    print_warning "Team ID not provided - skipping automated validation"
    echo ""
    print_status "Manual validation steps:"
    echo "1. Test archive creation with your Team ID"
    echo "2. Test IPA export with TestFlight export options"
    echo "3. Verify signing and provisioning profile"
fi

echo ""
echo "📋 Phase 2A Summary"
echo "=================="
echo ""
echo "Files created/updated:"
echo "✅ exportOptions-testflight.plist (TestFlight distribution)"
echo "✅ exportOptions-appstore.plist (Future App Store distribution)"
if [[ -f ".team-id-temp" ]]; then
    echo "✅ exportOptions.plist (Updated with Team ID)"
fi
echo ""
echo "Next steps:"
echo "1. Complete manual Apple Developer Portal tasks (2A.1-2A.4)"
echo "2. Provide Team ID for export options update"
echo "3. Test local signed archive creation"
echo "4. Proceed to Phase 2B: Build Pipeline Configuration"
echo ""
print_success "Phase 2A preparation complete!"
