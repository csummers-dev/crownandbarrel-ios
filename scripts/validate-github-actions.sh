#!/bin/bash

# GitHub Actions Workflow Validation Script
# This script validates GitHub Actions workflow files before pushing changes

set -e

echo "🔍 GitHub Actions Workflow Validation"
echo "===================================="

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

# Check if .github/workflows directory exists
if [ ! -d ".github/workflows" ]; then
    print_status "error" ".github/workflows directory not found"
    exit 1
fi

print_status "info" "Found .github/workflows directory"

# Find all workflow files
WORKFLOW_FILES=$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null || true)

if [ -z "$WORKFLOW_FILES" ]; then
    print_status "error" "No workflow files found in .github/workflows"
    exit 1
fi

print_status "info" "Found workflow files: $(echo $WORKFLOW_FILES | wc -w)"

# 1. Basic YAML syntax validation for all workflow files
print_status "info" "Validating YAML syntax for all workflow files..."

VALIDATION_FAILED=false

for workflow_file in $WORKFLOW_FILES; do
    if python3 -c "
import yaml
import sys
try:
    with open('$workflow_file', 'r') as f:
        yaml.safe_load(f)
    print('YAML syntax is valid: $workflow_file')
except yaml.YAMLError as e:
    print(f'YAML syntax error in $workflow_file: {e}')
    sys.exit(1)
except Exception as e:
    print(f'Error reading $workflow_file: {e}')
    sys.exit(1)
" 2>/dev/null; then
        print_status "success" "YAML syntax valid: $workflow_file"
    else
        print_status "error" "YAML syntax validation failed: $workflow_file"
        VALIDATION_FAILED=true
    fi
done

if [ "$VALIDATION_FAILED" = true ]; then
    exit 1
fi

# 2. GitHub Actions specific validation
print_status "info" "Validating GitHub Actions workflow structure..."

for workflow_file in $WORKFLOW_FILES; do
    if python3 -c "
import yaml
import sys

def validate_github_actions(config, filepath=''):
    errors = []
    
    if not isinstance(config, dict):
        errors.append(f'Root config must be a dictionary in {filepath}')
        return errors
    
    # Check required sections - handle YAML parsing quirks
    has_name = False
    has_on = False
    
    for key in config.keys():
        if str(key).lower() == 'name':
            has_name = True
        if str(key) == 'on' or str(key).lower() == 'on' or key is True:
            has_on = True
    
    if not has_name:
        errors.append(f'Missing required section \"name\" in {filepath}')
    if not has_on:
        errors.append(f'Missing required section \"on\" in {filepath}')
    
    # Validate name
    name_key = None
    for key in config.keys():
        if str(key).lower() == 'name':
            name_key = key
            break
    
    if name_key:
        if not isinstance(config[name_key], str):
            errors.append(f'name must be a string in {filepath}')
        elif len(config[name_key].strip()) == 0:
            errors.append(f'name cannot be empty in {filepath}')
    
    # Validate on triggers
    on_key = None
    for key in config.keys():
        if str(key) == 'on' or str(key).lower() == 'on' or key is True:
            on_key = key
            break
    
    if on_key:
        on_config = config[on_key]
        if not isinstance(on_config, (str, list, dict, bool)):
            errors.append(f'on must be string, list, dict, or bool in {filepath}')
    
    # Validate jobs
    if 'jobs' in config:
        jobs = config['jobs']
        if not isinstance(jobs, dict):
            errors.append(f'jobs must be a dictionary in {filepath}')
        else:
            for job_name, job_config in jobs.items():
                job_path = f'{filepath}.jobs.{job_name}'
                
                if not isinstance(job_config, dict):
                    errors.append(f'Job {job_name} must be a dictionary in {filepath}')
                    continue
                
                # Check required job fields
                if 'runs-on' not in job_config:
                    errors.append(f'Job {job_name} missing required \"runs-on\" field in {filepath}')
                
                # Validate steps
                if 'steps' in job_config:
                    steps = job_config['steps']
                    if not isinstance(steps, list):
                        errors.append(f'Job {job_name} steps must be a list in {filepath}')
                    else:
                        for i, step in enumerate(steps):
                            if not isinstance(step, dict):
                                errors.append(f'Job {job_name} step {i} must be a dictionary in {filepath}')
                                continue
                            
                            # Check for required step fields
                            if 'name' not in step and 'uses' not in step and 'run' not in step:
                                errors.append(f'Job {job_name} step {i} missing name, uses, or run in {filepath}')
    
    return errors

try:
    with open('$workflow_file', 'r') as f:
        config = yaml.safe_load(f)
    
    errors = validate_github_actions(config, '$workflow_file')
    
    if errors:
        print('GitHub Actions validation errors in $workflow_file:')
        for error in errors:
            print(f'  - {error}')
        sys.exit(1)
    else:
        print('GitHub Actions structure is valid: $workflow_file')
        
except Exception as e:
    print(f'Error during validation of $workflow_file: {e}')
    sys.exit(1)
" 2>/dev/null; then
        print_status "success" "GitHub Actions structure valid: $workflow_file"
    else
        print_status "error" "GitHub Actions structure validation failed: $workflow_file"
        VALIDATION_FAILED=true
    fi
done

if [ "$VALIDATION_FAILED" = true ]; then
    exit 1
fi

# 3. Check for common GitHub Actions issues
print_status "info" "Checking for common GitHub Actions issues..."

for workflow_file in $WORKFLOW_FILES; do
    # Check for hardcoded versions in actions
    if grep -q "uses: actions/" "$workflow_file"; then
        if grep -q "uses: actions/.*@main" "$workflow_file" || grep -q "uses: actions/.*@master" "$workflow_file"; then
            print_status "warning" "Found actions using @main or @master in $workflow_file - consider using specific versions"
        fi
    fi
    
    # Check for potential security issues
    if grep -q "shell: bash" "$workflow_file"; then
        if grep -q "run:" "$workflow_file" && grep -A 5 "run:" "$workflow_file" | grep -q "\${{" && ! grep -A 10 "run:" "$workflow_file" | grep -q "shell: bash"; then
            print_status "warning" "Found potential shell injection risk in $workflow_file - consider using shell: bash"
        fi
    fi
    
    # Check for missing permissions
    if grep -q "actions: write" "$workflow_file" || grep -q "contents: write" "$workflow_file"; then
        if ! grep -q "permissions:" "$workflow_file"; then
            print_status "warning" "Found write permissions without explicit permissions block in $workflow_file"
        fi
    fi
done

# 4. Validate action versions and availability
print_status "info" "Checking action versions and best practices..."

for workflow_file in $WORKFLOW_FILES; do
    # Extract action versions
    actions=$(grep "uses:" "$workflow_file" | grep -v "#" | sed 's/.*uses: *//' | sed 's/ *$//')
    
    for action in $actions; do
        if [[ $action == *"@"* ]]; then
            action_name=$(echo $action | cut -d'@' -f1)
            action_version=$(echo $action | cut -d'@' -f2)
            
            # Check for common problematic versions
            if [[ $action_version == "main" ]] || [[ $action_version == "master" ]]; then
                print_status "warning" "Action $action in $workflow_file uses @$action_version - consider using a specific version"
            fi
        else
            print_status "warning" "Action $action in $workflow_file missing version tag"
        fi
    done
done

# 5. Check for workflow dependencies and job dependencies
print_status "info" "Checking workflow dependencies..."

for workflow_file in $WORKFLOW_FILES; do
    if grep -q "needs:" "$workflow_file"; then
        if ! grep -q "if:" "$workflow_file"; then
            print_status "warning" "Found job dependencies without conditional logic in $workflow_file - consider adding if conditions"
        fi
    fi
done

# 6. Validate environment variables and secrets usage
print_status "info" "Validating environment variables and secrets..."

for workflow_file in $WORKFLOW_FILES; do
    # Check for proper secrets usage
    if grep -q "secrets\." "$workflow_file"; then
        if ! grep -q "env:" "$workflow_file"; then
            print_status "warning" "Found secrets usage without env block in $workflow_file - consider using env block"
        fi
    fi
    
    # Check for hardcoded sensitive values
    if grep -qi "password\|token\|key\|secret" "$workflow_file" | grep -v "secrets\." | grep -v "#"; then
        print_status "warning" "Found potential hardcoded sensitive values in $workflow_file - review for security"
    fi
done

# 7. Check for workflow optimization opportunities
print_status "info" "Checking for optimization opportunities..."

for workflow_file in $WORKFLOW_FILES; do
    # Check for caching opportunities
    if grep -q "npm install\|pip install\|bundle install\|go mod\|cargo build" "$workflow_file"; then
        if ! grep -q "actions/cache" "$workflow_file"; then
            print_status "warning" "Found package installation without caching in $workflow_file - consider adding cache"
        fi
    fi
    
    # Check for matrix strategies
    if grep -q "runs-on:" "$workflow_file" | wc -l | grep -q "1"; then
        if grep -q "build\|test" "$workflow_file"; then
            print_status "info" "Consider using matrix strategy for parallel builds in $workflow_file"
        fi
    fi
done

# 8. Test with GitHub Actions linter if available
print_status "info" "Testing with GitHub Actions linter..."

if command -v actionlint &> /dev/null; then
    for workflow_file in $WORKFLOW_FILES; do
        if actionlint "$workflow_file" 2>/dev/null; then
            print_status "success" "actionlint validation passed: $workflow_file"
        else
            print_status "warning" "actionlint found issues in $workflow_file (install with: brew install actionlint)"
        fi
    done
else
    print_status "info" "actionlint not available - install with: brew install actionlint"
fi

# 9. Generate summary
echo ""
echo "📊 Validation Summary"
echo "===================="
print_status "success" "All basic validations passed"

# Count workflow files
WORKFLOW_COUNT=$(echo $WORKFLOW_FILES | wc -w)
print_status "info" "Validated $WORKFLOW_COUNT workflow files"

# Check for common workflow types
CI_WORKFLOWS=$(echo $WORKFLOW_FILES | tr ' ' '\n' | grep -c "ci\|build\|test" || echo "0")
RELEASE_WORKFLOWS=$(echo $WORKFLOW_FILES | tr ' ' '\n' | grep -c "release\|deploy" || echo "0")
SECURITY_WORKFLOWS=$(echo $WORKFLOW_FILES | tr ' ' '\n' | grep -c "security\|scan" || echo "0")

print_status "info" "CI/Build workflows: $CI_WORKFLOWS"
print_status "info" "Release/Deploy workflows: $RELEASE_WORKFLOWS"
print_status "info" "Security workflows: $SECURITY_WORKFLOWS"

print_status "info" "Ready for GitHub Actions deployment"

# 10. Optional: Check if GitHub CLI is available for additional validation
if command -v gh &> /dev/null; then
    print_status "info" "GitHub CLI detected - you can run 'gh workflow list' to see workflows"
    if gh auth status &> /dev/null; then
        print_status "info" "GitHub CLI authenticated - you can validate workflows against GitHub"
    else
        print_status "info" "GitHub CLI not authenticated - run 'gh auth login' to enable advanced validation"
    fi
else
    print_status "info" "Install GitHub CLI (gh) for additional validation: brew install gh"
fi

echo ""
print_status "success" "GitHub Actions validation completed successfully!"
echo ""
echo "🚀 Your GitHub Actions workflows are ready to push!"
echo ""
