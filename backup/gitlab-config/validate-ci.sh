#!/bin/bash
set -euo pipefail

# Ensure we're using bash
if [ -z "$BASH_VERSION" ]; then
    echo "This script requires bash. Please run with: bash $0"
    exit 1
fi

# Crown & Barrel CI/CD Validation Script
# This script validates your CI/CD setup and checks for common issues

echo "🔍 Crown & Barrel CI/CD Validation"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Function to run a check
run_check() {
    local check_name="$1"
    local check_command="$2"
    local required="$3" # true/false
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -n "Checking $check_name... "
    
    if eval "$check_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}❌ FAIL${NC}"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        else
            echo -e "${YELLOW}⚠️  WARNING${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

# Function to check file exists and is readable
check_file() {
    local file_path="$1"
    local description="$2"
    local required="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo -n "Checking $description... "
    
    if [[ -f "$file_path" && -r "$file_path" ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}❌ FAIL${NC}"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        else
            echo -e "${YELLOW}⚠️  WARNING${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
}

echo ""
echo -e "${BLUE}📁 File Structure Validation${NC}"
echo "================================"

# Check required files
check_file ".gitlab-ci.yml" "GitLab CI configuration" "true"
check_file ".swiftlint.yml" "SwiftLint configuration" "true"
check_file "project.yml" "XcodeGen project configuration" "true"
check_file "exportOptions.plist" "Export options plist" "true"
check_file ".gitignore" "Git ignore file" "true"

# Check optional files
check_file "fastlane/Fastfile" "Fastlane configuration" "false"
check_file "fastlane/Appfile" "Fastlane app configuration" "false"
check_file "scripts/setup-ci.sh" "CI setup script" "false"

echo ""
echo -e "${BLUE}🔧 Tool Availability${NC}"
echo "======================"

# Check required tools
run_check "XcodeGen" "command -v xcodegen" "false"
run_check "SwiftLint" "command -v swiftlint" "false"
run_check "xcresulttool" "command -v xcresulttool" "false"
run_check "xcodebuild" "command -v xcodebuild" "true"
run_check "xcrun" "command -v xcrun" "true"

echo ""
echo -e "${BLUE}📱 iOS Environment${NC}"
echo "====================="

# Check Xcode version
echo -n "Checking Xcode version... "
if xcodebuild -version >/dev/null 2>&1; then
    XCODE_VERSION=$(xcodebuild -version | head -n1)
    echo -e "${GREEN}✅ $XCODE_VERSION${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ Xcode not found${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Check iOS Simulator
echo -n "Checking iOS Simulator... "
if xcrun simctl list devices available | grep -q "iPhone 16"; then
    echo -e "${GREEN}✅ iPhone 16 simulator available${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠️  iPhone 16 simulator not found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

echo ""
echo -e "${BLUE}📋 Project Configuration${NC}"
echo "=========================="

# Check project.yml syntax
echo -n "Checking project.yml syntax... "
if python3 -c "import yaml; yaml.safe_load(open('project.yml'))" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Valid YAML${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ Invalid YAML${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Check .gitlab-ci.yml syntax
echo -n "Checking .gitlab-ci.yml syntax... "
if python3 -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml'))" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Valid YAML${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ Invalid YAML${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Check exportOptions.plist syntax
echo -n "Checking exportOptions.plist syntax... "
if plutil -lint exportOptions.plist >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Valid plist${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}❌ Invalid plist${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

echo ""
echo -e "${BLUE}🧪 Build Test${NC}"
echo "============="

# Test project generation
echo -n "Testing project generation... "
if command -v xcodegen >/dev/null 2>&1; then
    if xcodegen generate >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Project generated successfully${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}❌ Project generation failed${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
else
    echo -e "${YELLOW}⚠️  XcodeGen not available${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Test SwiftLint
echo -n "Testing SwiftLint... "
if command -v swiftlint >/dev/null 2>&1; then
    if swiftlint lint --quiet >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SwiftLint passed${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${YELLOW}⚠️  SwiftLint found issues${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠️  SwiftLint not available${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

echo ""
echo -e "${BLUE}📊 Validation Summary${NC}"
echo "======================"
echo -e "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"

if [[ $FAILED_CHECKS -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}🎉 All required checks passed!${NC}"
    echo "Your CI/CD pipeline should work correctly."
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warnings found. Review them for optimal setup.${NC}"
    fi
    
    exit 0
else
    echo ""
    echo -e "${RED}❌ $FAILED_CHECKS required checks failed.${NC}"
    echo "Please fix these issues before running the CI/CD pipeline."
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  $WARNINGS warnings also found.${NC}"
    fi
    
    exit 1
fi
