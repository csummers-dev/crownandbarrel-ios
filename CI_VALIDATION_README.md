# GitHub Actions CI/CD Validation and Testing Guide

## 🎯 **Overview**

This guide explains how to validate and test GitHub Actions workflows before pushing to avoid pipeline creation errors.

## 🚨 **Common GitHub Actions Errors and Solutions**

### **Error: "Workflow syntax error"**

This error occurs when GitHub Actions workflow YAML doesn't follow the required syntax structure.

#### **Root Causes:**
1. **Missing required fields**: Missing `name`, `on`, or `jobs` sections
2. **Invalid YAML syntax**: Improper indentation or structure
3. **Action version issues**: Using `@main` or `@master` instead of specific versions
4. **Invalid job configuration**: Missing `runs-on` or improper `steps` structure

#### **Solutions Applied:**
- ✅ Comprehensive validation script for all workflow files
- ✅ YAML syntax validation with proper error reporting
- ✅ Action version pinning to specific stable versions
- ✅ Structure validation for required workflow fields

## 🔧 **Validation Tools**

### **1. GitHub Actions Validation Script**

**Location**: `scripts/validate-github-actions.sh`

**Features**:
- ✅ YAML syntax validation for all workflow files
- ✅ GitHub Actions structure validation
- ✅ Action version and security checks
- ✅ Best practices detection and warnings
- ✅ Performance optimization suggestions

**Usage**:
```bash
./scripts/validate-github-actions.sh
```

### **2. Git Hooks for Automated Validation**

**Setup Script**: `scripts/setup-github-hooks.sh`

**Features**:
- ✅ Pre-commit hook for workflow validation
- ✅ Pre-push hook for additional validation
- ✅ Swift syntax checking
- ✅ YAML file validation

**Setup**:
```bash
./scripts/setup-github-hooks.sh
```

## 📋 **Validation Checklist**

### **Required Workflow Fields**
- [ ] `name` - Workflow name (string, non-empty)
- [ ] `on` - Trigger configuration (string, list, or dict)
- [ ] `jobs` - Job definitions (dictionary)

### **Job Requirements**
- [ ] `runs-on` - Runner specification
- [ ] `steps` - Step definitions (list of dictionaries)

### **Step Requirements**
- [ ] `name` OR `uses` OR `run` - At least one required
- [ ] Proper action versions (avoid `@main`, `@master`)
- [ ] Secure secrets usage

### **Security Best Practices**
- [ ] Use specific action versions
- [ ] Add caching for package installations
- [ ] Use matrix strategies for parallel builds
- [ ] Include proper permissions blocks
- [ ] Use environment variables for secrets

## 🧪 **Testing Workflows**

### **Local Testing**

**Option 1: Using `act` (Recommended)**
```bash
# Install act
brew install act

# Run workflows locally
act
```

**Option 2: Manual Validation**
```bash
# Validate all workflows
./scripts/validate-github-actions.sh

# Check specific workflow
python3 -c "
import yaml
with open('.github/workflows/ci.yml', 'r') as f:
    yaml.safe_load(f)
print('Workflow is valid')
"
```

### **GitHub Actions Testing**

1. **Push to feature branch**: Test workflows in isolated environment
2. **Create pull request**: Verify workflow triggers and execution
3. **Check workflow runs**: Monitor execution in GitHub Actions tab
4. **Review logs**: Identify and fix any issues

## 🔍 **Troubleshooting**

### **Common Issues and Solutions**

#### **Issue: "Invalid workflow file"**
**Solution**: Check YAML syntax and required fields
```bash
./scripts/validate-github-actions.sh
```

#### **Issue: "Action not found"**
**Solution**: Verify action name and version
```bash
# Check action exists
curl -s "https://api.github.com/repos/OWNER/REPO/actions/workflows"
```

#### **Issue: "Permission denied"**
**Solution**: Add required permissions to workflow
```yaml
permissions:
  contents: read
  actions: write
```

#### **Issue: "Runner not found"**
**Solution**: Use supported runner labels
```yaml
runs-on: ubuntu-latest  # or macos-latest, windows-latest
```

### **Debugging Steps**

1. **Check YAML syntax**:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
   ```

2. **Validate workflow structure**:
   ```bash
   ./scripts/validate-github-actions.sh
   ```

3. **Test locally with act**:
   ```bash
   act -l  # List workflows
   act     # Run workflows
   ```

4. **Check GitHub Actions logs**:
   - Go to repository → Actions tab
   - Click on failed workflow run
   - Review step logs for specific errors

## 📊 **Validation Output**

### **Success Indicators**
```
✅ YAML syntax valid: .github/workflows/ci.yml
✅ GitHub Actions structure valid: .github/workflows/ci.yml
✅ All basic validations passed
🚀 Your GitHub Actions workflows are ready to push!
```

### **Warning Indicators**
```
⚠️  Found actions using @main - consider using specific versions
⚠️  Found write permissions without explicit permissions block
⚠️  Found package installation without caching - consider adding cache
```

### **Error Indicators**
```
❌ YAML syntax validation failed: .github/workflows/ci.yml
❌ Missing required section "name" in workflow
❌ Job build missing required "runs-on" field
```

## 🚀 **Best Practices**

### **Workflow Design**
- Use descriptive workflow and job names
- Organize jobs logically with proper dependencies
- Use matrix strategies for parallel execution
- Implement proper error handling and cleanup

### **Security**
- Pin all actions to specific versions
- Use GitHub Secrets for sensitive data
- Apply principle of least privilege
- Regular security scanning and updates

### **Performance**
- Use caching for dependencies
- Optimize workflow execution time
- Use appropriate runner types
- Clean up artifacts and temporary files

### **Maintenance**
- Regular dependency updates
- Monitor workflow performance
- Keep documentation updated
- Test changes in feature branches

## 📚 **Additional Resources**

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

## 🔄 **Continuous Improvement**

### **Regular Tasks**
- [ ] Update action versions monthly
- [ ] Review and optimize workflow performance
- [ ] Audit security configurations
- [ ] Update documentation as needed

### **Monitoring**
- [ ] Track workflow execution times
- [ ] Monitor failure rates
- [ ] Review security scan results
- [ ] Analyze cost and resource usage

---

**This validation system ensures reliable, secure, and efficient GitHub Actions workflows for the Crown & Barrel iOS app.**