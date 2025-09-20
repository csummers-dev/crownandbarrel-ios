#!/bin/bash

# GitLab CI/CD Pipeline Validation Script
# This script validates the .gitlab-ci.yml file before pushing changes

set -e

echo "🔍 GitLab CI/CD Pipeline Validation"
echo "=================================="

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

# Check if .gitlab-ci.yml exists
if [ ! -f ".gitlab-ci.yml" ]; then
    print_status "error" ".gitlab-ci.yml file not found"
    exit 1
fi

print_status "info" "Found .gitlab-ci.yml file"

# 1. Basic YAML syntax validation
print_status "info" "Validating YAML syntax..."
if python3 -c "
import yaml
import sys
try:
    with open('.gitlab-ci.yml', 'r') as f:
        yaml.safe_load(f)
    print('YAML syntax is valid')
except yaml.YAMLError as e:
    print(f'YAML syntax error: {e}')
    sys.exit(1)
except Exception as e:
    print(f'Error reading file: {e}')
    sys.exit(1)
" 2>/dev/null; then
    print_status "success" "YAML syntax is valid"
else
    print_status "error" "YAML syntax validation failed"
    exit 1
fi

# 2. GitLab CI specific validation
print_status "info" "Validating GitLab CI structure..."
if python3 -c "
import yaml
import sys

def validate_gitlab_ci(config, path=''):
    errors = []
    
    if not isinstance(config, dict):
        errors.append(f'Root config must be a dictionary at {path}')
        return errors
    
    # Check required sections
    required_sections = ['stages']
    for section in required_sections:
        if section not in config:
            errors.append(f'Missing required section: {section}')
    
    # Validate stages
    if 'stages' in config:
        if not isinstance(config['stages'], list):
            errors.append('stages must be a list')
        else:
            for i, stage in enumerate(config['stages']):
                if not isinstance(stage, str):
                    errors.append(f'stages[{i}] must be a string')
    
    # Validate jobs
    for key, value in config.items():
        if key.startswith('.') or key in ['stages', 'variables', 'cache', 'include', 'workflow', 'default']:
            continue
            
        if not isinstance(value, dict):
            continue
            
        job_path = f'{path}.{key}' if path else key
        
        # Check job structure
        if 'script' not in value:
            errors.append(f'Job {job_path} missing required script section')
        
        # Validate before_script
        if 'before_script' in value:
            before_script = value['before_script']
            if not isinstance(before_script, (str, list)):
                errors.append(f'Job {job_path} before_script must be string or list')
            elif isinstance(before_script, list):
                for i, item in enumerate(before_script):
                    if not isinstance(item, str):
                        errors.append(f'Job {job_path} before_script[{i}] must be string')
        
        # Validate script
        if 'script' in value:
            script = value['script']
            if not isinstance(script, (str, list)):
                errors.append(f'Job {job_path} script must be string or list')
            elif isinstance(script, list):
                for i, item in enumerate(script):
                    if not isinstance(item, str):
                        errors.append(f'Job {job_path} script[{i}] must be string')
        
        # Validate stage
        if 'stage' in value:
            if not isinstance(value['stage'], str):
                errors.append(f'Job {job_path} stage must be a string')
        
        # Validate extends
        if 'extends' in value:
            extends = value['extends']
            if not isinstance(extends, (str, list)):
                errors.append(f'Job {job_path} extends must be string or list')
    
    return errors

try:
    with open('.gitlab-ci.yml', 'r') as f:
        config = yaml.safe_load(f)
    
    errors = validate_gitlab_ci(config)
    
    if errors:
        print('GitLab CI validation errors:')
        for error in errors:
            print(f'  - {error}')
        sys.exit(1)
    else:
        print('GitLab CI structure is valid')
        
except Exception as e:
    print(f'Error during validation: {e}')
    sys.exit(1)
" 2>/dev/null; then
    print_status "success" "GitLab CI structure is valid"
else
    print_status "error" "GitLab CI structure validation failed"
    exit 1
fi

# 3. Check for common issues
print_status "info" "Checking for common issues..."

# Check for multiline scripts that might cause issues
if grep -q "|" .gitlab-ci.yml; then
    print_status "warning" "Found multiline scripts (|) - these can cause parsing issues"
fi

# Check for inline comments in arrays
if grep -A 5 -B 5 "before_script:" .gitlab-ci.yml | grep -q "#"; then
    print_status "warning" "Found potential inline comments in before_script arrays"
fi

# Check for variable usage issues
if grep -q '\$[A-Z_]*[^"]' .gitlab-ci.yml; then
    print_status "warning" "Found unquoted variables - consider quoting them"
fi

# 4. Validate against GitLab CI schema (if available)
print_status "info" "Checking GitLab CI best practices..."

# Check for proper job naming
if python3 -c "
import yaml
import re

with open('.gitlab-ci.yml', 'r') as f:
    config = yaml.safe_load(f)

job_names = [key for key in config.keys() if not key.startswith('.') and key not in ['stages', 'variables', 'cache', 'include', 'workflow', 'default']]

for job_name in job_names:
    if not re.match(r'^[a-zA-Z0-9_-]+$', job_name):
        print(f'Job name \"{job_name}\" contains invalid characters')
        exit(1)
    if job_name[0].isdigit():
        print(f'Job name \"{job_name}\" starts with a number')
        exit(1)

print('Job naming is valid')
" 2>/dev/null; then
    print_status "success" "Job naming follows best practices"
else
    print_status "warning" "Some job names may not follow best practices"
fi

# 5. Test YAML parsing with different parsers
print_status "info" "Testing with multiple YAML parsers..."

# Test with ruamel.yaml if available
if python3 -c "import ruamel.yaml" 2>/dev/null; then
    if python3 -c "
import ruamel.yaml
try:
    with open('.gitlab-ci.yml', 'r') as f:
        ruamel.yaml.safe_load(f)
    print('ruamel.yaml parsing successful')
except Exception as e:
    print(f'ruamel.yaml parsing failed: {e}')
    exit(1)
" 2>/dev/null; then
        print_status "success" "ruamel.yaml parsing successful"
    else
        print_status "warning" "ruamel.yaml parsing failed"
    fi
else
    print_status "info" "ruamel.yaml not available, skipping advanced validation"
fi

# 6. Generate summary
echo ""
echo "📊 Validation Summary"
echo "===================="
print_status "success" "All basic validations passed"
print_status "info" "Ready for GitLab CI/CD pipeline"

# 7. Optional: Check if GitLab CLI is available for additional validation
if command -v glab &> /dev/null; then
    print_status "info" "GitLab CLI detected - you can run 'glab ci lint' for additional validation"
else
    print_status "info" "Install GitLab CLI (glab) for additional validation: brew install glab"
fi

echo ""
print_status "success" "GitLab CI validation completed successfully!"
echo ""
echo "🚀 Your .gitlab-ci.yml is ready to push!"
echo ""
