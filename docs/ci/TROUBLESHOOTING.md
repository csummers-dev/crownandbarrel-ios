# CI/CD Pipeline Troubleshooting Guide

## Quick Reference

### Emergency Commands
```bash
# Validate all workflows
./test_security_pipeline.sh

# Check YAML syntax
find .github/workflows -name "*.yml" -exec python3 -c "import yaml; yaml.safe_load(open('{}'))" \;

# Check workflow structure
grep -l "name:" .github/workflows/*.yml
grep -l "on:" .github/workflows/*.yml
grep -l "jobs:" .github/workflows/*.yml
```

## Critical Security Issues

### 1. SARIF Upload Failures

**Symptoms:**
- Error: "Resource not accessible by integration"
- SARIF files not appearing in GitHub Security tab
- Security scan results not being uploaded

**Root Cause:**
Missing workflow-level permissions for GitHub Security tab access.

**Solution:**
```yaml
permissions:
  actions: read
  contents: read
  security-events: write  # Critical for SARIF upload
  packages: read
```

**Verification:**
```bash
grep -A 4 "permissions:" .github/workflows/security*.yml
```

### 2. TruffleHog BASE/HEAD Commit Errors

**Symptoms:**
- Error: "BASE and HEAD commits are the same"
- TruffleHog fails to scan
- Secret scanning job fails

**Root Cause:**
Git commit comparison issues in CI environment.

**Solution:**
```yaml
- name: Run TruffleHog secret scanner
  uses: trufflesecurity/trufflehog@v3.90.8
  continue-on-error: true
  with:
    path: ./
    extra_args: --debug --only-verified filesystem  # Use filesystem scan
```

**Verification:**
```bash
grep -A 5 "trufflesecurity/trufflehog" .github/workflows/security*.yml
```

### 3. Python Environment Issues

**Symptoms:**
- Error: "externally-managed-environment"
- Security tools fail to install
- pip installation blocked

**Root Cause:**
System Python environment conflicts.

**Solution:**
```yaml
- name: Install security tools
  run: |
    pipx install semgrep
    pipx install safety
    pipx install bandit
```

**Verification:**
```bash
grep -A 3 "pipx install" .github/workflows/security*.yml
```

### 4. Action Version Issues

**Symptoms:**
- Error: "Unable to resolve action"
- Actions not found
- Version compatibility issues

**Root Cause:**
Using non-existent or incompatible action versions.

**Solution:**
Use stable, tested versions:
```yaml
uses: aquasecurity/trivy-action@0.32.0  # Stable version
uses: github/codeql-action/upload-sarif@v3  # Current version
uses: maxim-lobanov/setup-xcode@v1  # Stable version
```

**Verification:**
```bash
grep "uses:" .github/workflows/*.yml | grep -E "@(main|master|[0-9]+\.[0-9]+\.[0-9]+)"
```

## Build Issues

### 1. Xcode Version Issues

**Symptoms:**
- Error: "Xcode version not found"
- Build fails with version errors
- Simulator not available

**Root Cause:**
Unsupported or unavailable Xcode versions.

**Solution:**
```yaml
- name: Setup Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: 'latest-stable'  # Use latest stable
```

**Verification:**
```bash
grep -A 2 "setup-xcode" .github/workflows/*.yml
```

### 2. iOS Simulator Issues

**Symptoms:**
- Error: "Simulator not available"
- iOS version not found
- Build destination errors

**Root Cause:**
Unsupported iOS versions or simulator configurations.

**Solution:**
```yaml
# Use supported iOS versions
- name: Build for iOS Simulator
  run: |
    xcodebuild build \
      -destination "platform=iOS Simulator,name=iPhone 15 Pro,OS=18.2" \
      IPHONEOS_DEPLOYMENT_TARGET=17.0
```

**Supported iOS Versions:**
- iOS 18.2
- iOS 18.1
- iOS 17.5

**Verification:**
```bash
grep -E "OS=[0-9]" .github/workflows/*.yml
```

### 3. Build Performance Issues

**Symptoms:**
- Slow builds
- Timeout errors
- Resource exhaustion

**Root Cause:**
Inefficient build configuration or resource constraints.

**Solution:**
```yaml
# Optimize build configuration
- name: Build with optimization
  run: |
    xcodebuild build \
      -quiet \
      -jobs 4 \
      -destination "$DESTINATION" \
      CODE_SIGNING_ALLOWED=NO \
      ENABLE_BITCODE=NO
```

**Verification:**
```bash
grep -A 5 "xcodebuild build" .github/workflows/*.yml
```

## Validation Issues

### 1. Workflow Structure Validation

**Symptoms:**
- Error: "Missing required section"
- GitHub Actions validation fails
- Workflow not recognized

**Root Cause:**
Missing required workflow fields or syntax errors.

**Solution:**
Ensure all workflows have:
```yaml
name: Workflow Name
on:
  push:
    branches: [main]
jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
      - name: Step Name
        run: echo "Hello"
```

**Verification:**
```bash
python3 -c "
import yaml
for wf in ['.github/workflows/ci.yml', '.github/workflows/security.yml']:
    with open(wf) as f:
        workflow = yaml.safe_load(f)
    assert 'name' in workflow, f'{wf} missing name'
    assert 'on' in workflow or True in workflow, f'{wf} missing on'
    assert 'jobs' in workflow, f'{wf} missing jobs'
"
```

### 2. YAML Syntax Issues

**Symptoms:**
- Error: "YAML syntax error"
- Workflow parsing fails
- Indentation errors

**Root Cause:**
Invalid YAML syntax or indentation.

**Solution:**
```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/workflow.yml'))"
```

**Common Fixes:**
- Use spaces, not tabs
- Consistent indentation (2 spaces)
- Proper quoting for special characters
- Valid YAML structure

**Verification:**
```bash
find .github/workflows -name "*.yml" -exec python3 -c "import yaml; yaml.safe_load(open('{}'))" \;
```

## Performance Issues

### 1. Slow Pipeline Execution

**Symptoms:**
- Long execution times
- Timeout errors
- Resource constraints

**Root Cause:**
Inefficient workflow configuration or resource limitations.

**Solution:**
```yaml
# Optimize workflow
- name: Parallel job execution
  strategy:
    matrix:
      include:
        - os: ubuntu-latest
        - os: macos-latest
  
- name: Efficient caching
  uses: actions/cache@v4
  with:
    path: ~/Library/Caches
    key: ${{ runner.os }}-cache-${{ hashFiles('**/Package.resolved') }}
```

**Verification:**
```bash
grep -A 3 "strategy:" .github/workflows/*.yml
grep -A 5 "actions/cache" .github/workflows/*.yml
```

### 2. Memory Issues

**Symptoms:**
- Out of memory errors
- Process killed
- Resource exhaustion

**Root Cause:**
Large dependencies or inefficient resource usage.

**Solution:**
```yaml
# Optimize resource usage
- name: Clean build
  run: |
    xcodebuild clean
    rm -rf ~/Library/Developer/Xcode/DerivedData
    
- name: Efficient dependency management
  run: |
    swift package resolve --verbose
    swift package clean
```

**Verification:**
```bash
grep -A 3 "xcodebuild clean" .github/workflows/*.yml
```

## Monitoring and Debugging

### 1. Workflow Logs

**Access:**
- GitHub Actions tab
- Individual workflow runs
- Step-by-step logs

**Key Information:**
- Execution time per step
- Error messages
- Environment variables
- Artifact outputs

### 2. Debugging Commands

```bash
# Check workflow status
gh workflow list

# View workflow runs
gh run list

# Download workflow logs
gh run download <run-id>

# Rerun failed workflow
gh run rerun <run-id>
```

### 3. Local Testing

```bash
# Test workflow locally
act -j job-name

# Validate workflow syntax
yamllint .github/workflows/*.yml

# Test specific workflow
act -W .github/workflows/security.yml
```

## Emergency Procedures

### 1. Critical Pipeline Failure

1. **Immediate Response:**
   - Check GitHub Actions status
   - Review error logs
   - Identify affected workflows

2. **Quick Fixes:**
   - Add `continue-on-error: true` to failing steps
   - Use stable action versions
   - Verify permissions

3. **Recovery:**
   - Revert to last working configuration
   - Apply fixes incrementally
   - Test thoroughly before deployment

### 2. Security Pipeline Failure

1. **Immediate Response:**
   - Verify security tools are working
   - Check permissions
   - Review error handling

2. **Quick Fixes:**
   - Use filesystem scan for TruffleHog
   - Add proper permissions
   - Use `pipx` for Python tools

3. **Recovery:**
   - Test security pipeline locally
   - Validate all security tools
   - Deploy with comprehensive testing

## Prevention Strategies

### 1. Pre-Deployment Validation

```bash
# Run comprehensive validation
./test_security_pipeline.sh

# Check all workflows
find .github/workflows -name "*.yml" -exec python3 -c "import yaml; yaml.safe_load(open('{}'))" \;

# Validate structure
grep -q "name:" .github/workflows/*.yml
grep -q "on:" .github/workflows/*.yml
grep -q "jobs:" .github/workflows/*.yml
```

### 2. Regular Maintenance

- **Weekly**: Review security pipeline status
- **Monthly**: Update action versions
- **Quarterly**: Review and optimize workflows

### 3. Documentation Updates

- Keep troubleshooting guide current
- Document new issues and solutions
- Update best practices regularly

---

*Last Updated: $(date)*
*Troubleshooting Guide Version: 1.0*
