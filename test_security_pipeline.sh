#!/bin/bash

echo "🔍 COMPREHENSIVE SECURITY PIPELINE TESTING"
echo "=========================================="

# Test 1: YAML Syntax Validation
echo ""
echo "1. YAML Syntax Validation:"
python3 -c "
import yaml
import sys

workflows = ['.github/workflows/security.yml', '.github/workflows/security-audit.yml']
all_valid = True

for wf in workflows:
    try:
        with open(wf, 'r') as f:
            yaml.safe_load(f)
        print(f'  ✅ {wf} - Valid YAML syntax')
    except Exception as e:
        print(f'  ❌ {wf} - YAML Error: {e}')
        all_valid = False

if all_valid:
    print('  🎉 All security workflows have valid YAML syntax!')
    exit(0)
else:
    print('  ⚠️ Some workflows have syntax errors.')
    exit(1)
"

YAML_RESULT=$?

# Test 2: Security Tool Configuration Analysis
echo ""
echo "2. Security Tool Configuration Analysis:"
python3 -c "
import yaml
import sys

def analyze_security_tools(wf_path):
    print(f'\\n📋 Analyzing {wf_path}:')
    try:
        with open(wf_path, 'r') as f:
            workflow = yaml.safe_load(f)
        
        issues = []
        
        # Check workflow permissions
        if 'permissions' not in workflow:
            issues.append('Missing workflow-level permissions')
        else:
            required_perms = ['actions', 'contents', 'security-events']
            for perm in required_perms:
                if perm not in workflow['permissions']:
                    issues.append(f'Missing {perm} permission')
        
        # Check each job
        for job_name, job_config in workflow.get('jobs', {}).items():
            print(f'\\n  🔧 Job: {job_name}')
            
            # Check for security tools and error handling
            if 'steps' in job_config:
                for step in job_config['steps']:
                    if 'uses' in step:
                        action = step['uses']
                        if any(tool in action for tool in ['trivy', 'trufflehog', 'codeql']):
                            print(f'    🔒 Security tool: {action}')
                            if 'continue-on-error' not in step:
                                issues.append(f'{job_name}: {action} missing continue-on-error')
                            else:
                                print(f'      ✅ Has continue-on-error protection')
        
        if issues:
            print(f'\\n  ⚠️ Issues found:')
            for issue in issues:
                print(f'    - {issue}')
            return False
        else:
            print(f'\\n  ✅ No issues found')
            return True
            
    except Exception as e:
        print(f'  ❌ Error analyzing {wf_path}: {e}')
        return False

# Analyze both workflows
security_ok = analyze_security_tools('.github/workflows/security.yml')
audit_ok = analyze_security_tools('.github/workflows/security-audit.yml')

if security_ok and audit_ok:
    print('\\n🎉 All security configurations are properly set up!')
    exit(0)
else:
    print('\\n⚠️ Security configuration issues found.')
    exit(1)
"

CONFIG_RESULT=$?

# Test 3: Action Version Validation
echo ""
echo "3. Action Version Validation:"
python3 -c "
import yaml
import re

def validate_action_versions(wf_path):
    print(f'\\n📋 Validating action versions in {wf_path}:')
    try:
        with open(wf_path, 'r') as f:
            content = f.read()
        
        # Check for problematic patterns
        issues = []
        
        # Check for unpinned versions
        unpinned = re.findall(r'uses:\s+[^@\s]+@(?:main|master)', content)
        if unpinned:
            issues.append(f'Unpinned versions found: {unpinned}')
        
        # Check for known problematic versions
        if 'trivy-action@0.34.0' in content:
            issues.append('Problematic Trivy version 0.34.0 found')
        
        if issues:
            for issue in issues:
                print(f'  ⚠️ {issue}')
            return False
        else:
            print(f'  ✅ All action versions look good')
            return True
            
    except Exception as e:
        print(f'  ❌ Error validating {wf_path}: {e}')
        return False

security_versions = validate_action_versions('.github/workflows/security.yml')
audit_versions = validate_action_versions('.github/workflows/security-audit.yml')

if security_versions and audit_versions:
    print('\\n🎉 All action versions are valid!')
    exit(0)
else:
    print('\\n⚠️ Action version issues found.')
    exit(1)
"

VERSION_RESULT=$?

# Summary
echo ""
echo "📊 TESTING SUMMARY"
echo "=================="
echo "YAML Syntax: $([ $YAML_RESULT -eq 0 ] && echo '✅ PASS' || echo '❌ FAIL')"
echo "Configuration: $([ $CONFIG_RESULT -eq 0 ] && echo '✅ PASS' || echo '❌ FAIL')"
echo "Action Versions: $([ $VERSION_RESULT -eq 0 ] && echo '✅ PASS' || echo '❌ FAIL')"

if [ $YAML_RESULT -eq 0 ] && [ $CONFIG_RESULT -eq 0 ] && [ $VERSION_RESULT -eq 0 ]; then
    echo ""
    echo "🎉 ALL TESTS PASSED - SECURITY PIPELINE READY!"
    exit 0
else
    echo ""
    echo "⚠️ SOME TESTS FAILED - NEEDS FIXES BEFORE DEPLOYMENT"
    exit 1
fi
