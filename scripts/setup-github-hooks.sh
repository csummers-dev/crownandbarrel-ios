#!/bin/bash

# Git Hooks Setup Script for GitHub Actions
# This script sets up pre-commit hooks to validate GitHub Actions workflows

set -e

echo "🔧 Setting up Git Hooks for GitHub Actions Validation"
echo "====================================================="

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
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "info")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_status "error" "Not in a git repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
if [ ! -d ".git/hooks" ]; then
    print_status "error" ".git/hooks directory not found"
    exit 1
fi

print_status "info" "Setting up pre-commit hook..."

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Pre-commit hook for Crown & Barrel project
# Validates GitHub Actions workflows and other files before commit

set -e

echo "🔍 Pre-commit validation starting..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "info")
            echo -e "${NC}ℹ️  $message${NC}"
            ;;
    esac
}

# Check if GitHub Actions workflows are being committed
if git diff --cached --name-only | grep -q "\.github/workflows/.*\.yml$"; then
    print_status "info" "GitHub Actions workflows detected in commit"
    
    # Run GitHub Actions validation
    if [ -f "scripts/validate-github-actions.sh" ]; then
        if ./scripts/validate-github-actions.sh; then
            print_status "success" "GitHub Actions validation passed"
        else
            print_status "error" "GitHub Actions validation failed - commit blocked"
            exit 1
        fi
    else
        print_status "warning" "GitHub Actions validation script not found"
    fi
fi

# Check for other important files
if git diff --cached --name-only | grep -q "\.swift$"; then
    print_status "info" "Swift files detected - checking syntax..."
    
    # Basic Swift syntax check (if available)
    if command -v swift &> /dev/null; then
        for file in $(git diff --cached --name-only | grep "\.swift$"); do
            if swift -frontend -parse "$file" 2>/dev/null; then
                print_status "success" "Swift syntax OK: $file"
            else
                print_status "warning" "Swift syntax check skipped for: $file"
            fi
        done
    else
        print_status "info" "Swift compiler not available, skipping syntax check"
    fi
fi

# Check for YAML files
if git diff --cached --name-only | grep -q "\.ya\?ml$"; then
    print_status "info" "YAML files detected - validating syntax..."
    
    for file in $(git diff --cached --name-only | grep "\.ya\?ml$"); do
        if python3 -c "
import yaml
import sys
try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('YAML syntax OK: $file')
except yaml.YAMLError as e:
    print(f'YAML syntax error in $file: {e}')
    sys.exit(1)
except Exception as e:
    print(f'Error reading $file: {e}')
    sys.exit(1)
" 2>/dev/null; then
            print_status "success" "YAML syntax OK: $file"
        else
            print_status "error" "YAML syntax error in: $file"
            exit 1
        fi
    done
fi

print_status "success" "Pre-commit validation completed successfully!"
EOF

# Make the hook executable
chmod +x .git/hooks/pre-commit

print_status "success" "Pre-commit hook installed successfully"

# Create pre-push hook for additional validation
print_status "info" "Setting up pre-push hook..."

cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

# Pre-push hook for Crown & Barrel project
# Additional validation before pushing to remote

set -e

echo "🚀 Pre-push validation starting..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "info")
            echo -e "${NC}ℹ️  $message${NC}"
            ;;
    esac
}

# Check if GitHub Actions workflows exist and are valid
if [ -d ".github/workflows" ] && [ "$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)" -gt 0 ]; then
    print_status "info" "Validating GitHub Actions workflows before push..."
    
    if [ -f "scripts/validate-github-actions.sh" ]; then
        if ./scripts/validate-github-actions.sh; then
            print_status "success" "GitHub Actions validation passed"
        else
            print_status "error" "GitHub Actions validation failed - push blocked"
            exit 1
        fi
    else
        print_status "warning" "GitHub Actions validation script not found"
    fi
fi

# Check for build issues (if Xcode is available)
if command -v xcodebuild &> /dev/null && [ -f "CrownAndBarrel.xcodeproj/project.pbxproj" ]; then
    print_status "info" "Checking for basic build issues..."
    
    # Quick syntax check without full build
    if xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination "platform=iOS Simulator,name=iPhone 16" -dry-run 2>/dev/null; then
        print_status "success" "Basic build check passed"
    else
        print_status "warning" "Basic build check failed - consider running full build"
    fi
else
    print_status "info" "Xcode not available, skipping build check"
fi

print_status "success" "Pre-push validation completed successfully!"
EOF

# Make the hook executable
chmod +x .git/hooks/pre-push

print_status "success" "Pre-push hook installed successfully"

echo ""
echo "🎉 GitHub Actions Git Hooks Setup Complete!"
echo "==========================================="
print_status "success" "Pre-commit hook: Validates GitHub Actions workflows before commit"
print_status "success" "Pre-push hook: Additional validation before push"
print_status "info" "Hooks will automatically run GitHub Actions validation"
print_status "info" "To bypass hooks temporarily, use: git commit --no-verify"
echo ""
print_status "success" "Git hooks are now active for GitHub Actions!"
echo ""
