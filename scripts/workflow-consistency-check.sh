#!/bin/bash
# Workflow Consistency Checker
# This script verifies that all GitHub Actions workflows are consistent and up-to-date

set -e

echo "🔍 CrownAndBarrel iOS Workflow Consistency Check"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -d ".github/workflows" ]; then
    echo -e "${RED}❌ Error: .github/workflows directory not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo -e "${BLUE}📁 Found workflow directory: .github/workflows${NC}"

# List all workflow files
echo -e "\n${BLUE}📋 Workflow Files:${NC}"
find .github/workflows -name "*.yml" -type f | sort | while read -r file; do
    echo "  - $file"
done

# Count total workflows
WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -type f | wc -l)
echo -e "\n${BLUE}📊 Total workflows found: $WORKFLOW_COUNT${NC}"

# Check for common patterns that should be consistent
echo -e "\n${BLUE}🔍 Checking for common patterns...${NC}"

PATTERNS=(
    "xcodegen.zip:Old XcodeGen installation method"
    "xcodegen.artifactbundle.zip:New XcodeGen artifact bundle method"
    "generic/platform=iOS Simulator:Problematic simulator destination"
    "platform=iOS Simulator,name=iPhone.*OS=26.0:New dynamic simulator destination"
    "IPHONEOS_DEPLOYMENT_TARGET:Build target configuration"
    "brew install:Homebrew installation"
    "arch -arm64.*brew:ARM64 Homebrew installation"
)

INCONSISTENCIES=0

for pattern_info in "${PATTERNS[@]}"; do
    IFS=':' read -r pattern description <<< "$pattern_info"
    
    echo -e "\n${YELLOW}🔍 Checking: $description${NC}"
    echo "   Pattern: $pattern"
    
    matches=$(grep -r "$pattern" .github/workflows/ 2>/dev/null | wc -l || echo "0")
    
    if [ "$matches" -gt 0 ]; then
        echo -e "   ${YELLOW}Found $matches occurrences in:${NC}"
        grep -r "$pattern" .github/workflows/ 2>/dev/null | cut -d: -f1 | sort | uniq | while read -r file; do
            echo "     - $file"
        done
        
        # Check for potential inconsistencies
        if [[ "$pattern" == "xcodegen.zip" && "$matches" -gt 0 ]]; then
            echo -e "   ${RED}⚠️  WARNING: Found old XcodeGen installation method${NC}"
            INCONSISTENCIES=$((INCONSISTENCIES + 1))
        fi
        
        if [[ "$pattern" == "generic/platform=iOS Simulator" && "$matches" -gt 0 ]]; then
            echo -e "   ${RED}⚠️  WARNING: Found problematic simulator destination${NC}"
            INCONSISTENCIES=$((INCONSISTENCIES + 1))
        fi
    else
        echo -e "   ${GREEN}✅ No occurrences found${NC}"
    fi
done

# Check for workflow-specific issues
echo -e "\n${BLUE}🔍 Checking for workflow-specific issues...${NC}"

# Check if CodeQL has build step
if grep -q "codeql-action/analyze" .github/workflows/security.yml; then
    if ! grep -q "Build for CodeQL Analysis" .github/workflows/security.yml; then
        echo -e "${RED}❌ CodeQL Analysis missing build step in security.yml${NC}"
        INCONSISTENCIES=$((INCONSISTENCIES + 1))
    else
        echo -e "${GREEN}✅ CodeQL Analysis has proper build step${NC}"
    fi
fi

# Check for XcodeGen installation patterns
XCODEGEN_INSTALLS=$(grep -l "xcodegen" .github/workflows/*.yml | wc -l)
echo -e "\n${BLUE}📊 Workflows using XcodeGen: $XCODEGEN_INSTALLS${NC}"

# Check for simulator usage
SIMULATOR_USAGE=$(grep -l "xcodebuild.*destination" .github/workflows/*.yml | wc -l)
echo -e "${BLUE}📊 Workflows using xcodebuild destinations: $SIMULATOR_USAGE${NC}"

# Summary
echo -e "\n${BLUE}📋 Summary${NC}"
echo "=========="

if [ $INCONSISTENCIES -eq 0 ]; then
    echo -e "${GREEN}✅ All workflows appear consistent${NC}"
    echo -e "${GREEN}✅ No critical issues found${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $INCONSISTENCIES potential inconsistencies${NC}"
    echo -e "${YELLOW}⚠️  Please review the warnings above${NC}"
    echo -e "\n${BLUE}💡 Recommendations:${NC}"
    echo "  1. Review the Pipeline Maintenance Guide: docs/PIPELINE_MAINTENANCE_GUIDE.md"
    echo "  2. Apply fixes systematically across ALL workflows"
    echo "  3. Use the systematic update process for consistency"
    exit 1
fi
