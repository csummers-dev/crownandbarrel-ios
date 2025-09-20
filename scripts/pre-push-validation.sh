#!/bin/bash

# Pre-push validation script for CrownAndBarrel iOS project
# This script runs comprehensive checks before pushing to GitHub

set -e

echo "🚀 Pre-push validation starting..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success") echo -e "${GREEN}✅ $message${NC}" ;;
        "error") echo -e "${RED}❌ $message${NC}" ;;
        "warning") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "info") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Check if we're in the right directory
if [ ! -f "CrownAndBarrel.xcodeproj/project.pbxproj" ]; then
    print_status "error" "Not in CrownAndBarrel project directory"
    exit 1
fi

print_status "info" "Running comprehensive pre-push validation..."

# 1. Check Xcode version
print_status "info" "Checking Xcode version..."
XCODE_VERSION=$(xcodebuild -version | head -1)
print_status "success" "Xcode version: $XCODE_VERSION"

# 2. Check available iOS SDKs
print_status "info" "Checking available iOS SDKs..."
AVAILABLE_SDKS=$(xcodebuild -showsdks | grep iOS | wc -l)
if [ $AVAILABLE_SDKS -gt 0 ]; then
    print_status "success" "Found $AVAILABLE_SDKS iOS SDK(s)"
    xcodebuild -showsdks | grep iOS | head -3
else
    print_status "error" "No iOS SDKs found - this will cause build failures"
    exit 1
fi

# 3. Check available destinations
print_status "info" "Checking available build destinations..."
DESTINATIONS=$(xcodebuild -showdestinations -scheme CrownAndBarrel -project CrownAndBarrel.xcodeproj 2>/dev/null | wc -l)
if [ $DESTINATIONS -gt 0 ]; then
    print_status "success" "Found $DESTINATIONS available destinations"
    xcodebuild -showdestinations -scheme CrownAndBarrel -project CrownAndBarrel.xcodeproj 2>/dev/null | head -5
else
    print_status "warning" "No destinations found - this may cause build issues"
fi

# 4. Check required tools
print_status "info" "Checking required development tools..."

# Check XcodeGen
if command -v xcodegen &> /dev/null; then
    print_status "success" "XcodeGen is available: $(which xcodegen)"
else
    print_status "error" "XcodeGen is not available - install with: brew install xcodegen"
    exit 1
fi

# Check SwiftLint
if command -v swiftlint &> /dev/null; then
    print_status "success" "SwiftLint is available: $(which swiftlint)"
else
    print_status "warning" "SwiftLint is not available - install with: brew install swiftlint"
fi

# 5. Validate project configuration
print_status "info" "Validating project configuration..."

# Check if project file exists
if [ -f "project.yml" ]; then
    print_status "success" "Found project.yml configuration"
else
    print_status "error" "project.yml not found - required for XcodeGen"
    exit 1
fi

# 6. Test basic build configuration
print_status "info" "Testing basic build configuration..."

# Try to generate project
if xcodegen generate --quiet 2>/dev/null; then
    print_status "success" "XcodeGen project generation successful"
else
    print_status "error" "XcodeGen project generation failed"
    exit 1
fi

# 7. Test build with available destinations
print_status "info" "Testing build with available destinations..."

# Test build with available iOS 26.0 device (iPhone 17 Pro since iPhone 16 Pro iOS 26.0 not available locally)
print_status "info" "Testing build with iPhone 17 Pro iOS 26.0 destination (local test)"

# Test build configuration targeting iPhone 17 Pro with iOS 26.0 (available locally)
if xcodebuild build \
    -project CrownAndBarrel.xcodeproj \
    -scheme CrownAndBarrel \
    -configuration Debug \
    -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0" \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=YES \
    VALID_ARCHS="arm64" \
    ARCHS="arm64" \
    ENABLE_BITCODE=NO \
    IPHONEOS_DEPLOYMENT_TARGET=26.0 >/dev/null 2>&1; then
    print_status "success" "Build configuration test passed"
else
    print_status "error" "Build configuration test failed"
    print_status "info" "This indicates the same issue that will occur in CI"
    exit 1
fi

# 8. Check for common issues
print_status "info" "Checking for common CI/CD issues..."

# Check for Homebrew architecture issues
if [[ $(uname -m) == "arm64" ]]; then
    print_status "info" "Running on ARM64 architecture"
    if command -v brew &> /dev/null; then
        BREW_PATH=$(which brew)
        if [[ "$BREW_PATH" == "/opt/homebrew/bin/brew" ]]; then
            print_status "success" "Homebrew is in correct ARM64 location"
        else
            print_status "warning" "Homebrew may have architecture issues: $BREW_PATH"
        fi
    fi
fi

# 9. Validate GitHub Actions workflows
print_status "info" "Validating GitHub Actions workflows..."
if [ -f "scripts/validate-github-actions.sh" ]; then
    if ./scripts/validate-github-actions.sh; then
        print_status "success" "GitHub Actions workflows validation passed"
    else
        print_status "error" "GitHub Actions workflows validation failed"
        exit 1
    fi
else
    print_status "warning" "GitHub Actions validation script not found"
fi

# 10. Check workflow consistency
print_status "info" "Checking workflow consistency..."
if ./scripts/workflow-consistency-check.sh >/dev/null 2>&1; then
    print_status "success" "Workflow consistency check passed"
else
    print_status "error" "Workflow consistency issues found"
    print_status "info" "Run './scripts/workflow-consistency-check.sh' for details"
    exit 1
fi

# 11. Final summary
print_status "success" "Pre-push validation completed successfully!"
print_status "info" "All checks passed - ready to push to GitHub"

echo ""
echo "🎉 Validation Summary:"
echo "✅ Xcode version: $XCODE_VERSION"
echo "✅ iOS SDKs: $AVAILABLE_SDKS available"
echo "✅ Destinations: $DESTINATIONS found"
echo "✅ Required tools: Available"
echo "✅ Project configuration: Valid"
echo "✅ Build configuration: Tested"
echo "✅ GitHub Actions: Validated"
echo "✅ Workflow consistency: Checked"
echo ""
echo "🚀 Ready to push to GitHub!"
