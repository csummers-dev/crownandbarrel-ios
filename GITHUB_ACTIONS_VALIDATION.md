# GitHub Actions Validation System
## Crown & Barrel iOS App - CI/CD Validation

### 🎯 **Overview**

This document describes the validation system for GitHub Actions workflows in the Crown & Barrel iOS app project.

### 🔧 **Validation Scripts**

#### **`scripts/validate-github-actions.sh`**
Comprehensive validation script for GitHub Actions workflows:

**Features:**
- ✅ YAML syntax validation for all workflow files
- ✅ GitHub Actions structure validation
- ✅ Common issue detection and warnings
- ✅ Action version and security checks
- ✅ Workflow optimization suggestions
- ✅ Integration with actionlint (if available)

**Usage:**
```bash
./scripts/validate-github-actions.sh
```

#### **`scripts/setup-github-hooks.sh`**
Git hooks setup for automated validation:

**Features:**
- ✅ Pre-commit hook for workflow validation
- ✅ Pre-push hook for additional validation
- ✅ Swift syntax checking
- ✅ YAML file validation
- ✅ Build issue detection

**Usage:**
```bash
./scripts/setup-github-hooks.sh
```

### 🔍 **Validation Checks**

#### **1. YAML Syntax Validation**
- Validates all `.yml` and `.yaml` files in `.github/workflows/`
- Checks for proper YAML structure and syntax
- Reports specific error locations

#### **2. GitHub Actions Structure Validation**
- Validates required fields: `name`, `on`, `jobs`
- Checks job structure: `runs-on`, `steps`
- Validates step structure and required fields
- Ensures proper workflow dependencies

#### **3. Security and Best Practices**
- Checks for hardcoded secrets or sensitive values
- Validates proper secrets usage with `secrets.` syntax
- Warns about actions using `@main` or `@master`
- Checks for proper permissions configuration

#### **4. Optimization Opportunities**
- Identifies caching opportunities
- Suggests matrix strategies for parallel builds
- Checks for workflow dependency optimization
- Validates environment variable usage

### 🚨 **Common Issues Detected**

#### **Security Issues:**
- Hardcoded passwords, tokens, or API keys
- Missing permissions blocks for write operations
- Actions using unstable versions (`@main`, `@master`)

#### **Performance Issues:**
- Missing caching for package installations
- Single-run jobs that could use matrix strategies
- Inefficient workflow dependencies

#### **Structure Issues:**
- Missing required workflow fields
- Invalid job or step configurations
- Improper YAML syntax

### 📊 **Validation Output**

#### **Success Indicators:**
```
✅ YAML syntax valid: .github/workflows/ci.yml
✅ GitHub Actions structure valid: .github/workflows/ci.yml
✅ All basic validations passed
🚀 Your GitHub Actions workflows are ready to push!
```

#### **Warning Indicators:**
```
⚠️  Found actions using @main - consider using specific versions
⚠️  Found write permissions without explicit permissions block
⚠️  Found package installation without caching - consider adding cache
```

#### **Error Indicators:**
```
❌ YAML syntax validation failed: .github/workflows/ci.yml
❌ GitHub Actions structure validation failed
❌ Missing required section "name" in workflow
```

### 🔧 **Integration with Git Hooks**

#### **Pre-commit Hook:**
- Automatically validates GitHub Actions workflows
- Checks Swift syntax for modified files
- Validates YAML files
- Blocks commit if validation fails

#### **Pre-push Hook:**
- Additional validation before pushing
- Checks all GitHub Actions workflows
- Basic build validation (if Xcode available)
- Blocks push if critical issues found

### 📋 **Workflow Validation Checklist**

#### **Required Fields:**
- [ ] `name` - Workflow name (string, non-empty)
- [ ] `on` - Trigger configuration (string, list, or dict)
- [ ] `jobs` - Job definitions (dictionary)

#### **Job Requirements:**
- [ ] `runs-on` - Runner specification
- [ ] `steps` - Step definitions (list of dictionaries)

#### **Step Requirements:**
- [ ] `name` OR `uses` OR `run` - At least one required
- [ ] Proper action versions (avoid `@main`, `@master`)
- [ ] Secure secrets usage

#### **Best Practices:**
- [ ] Use specific action versions
- [ ] Add caching for package installations
- [ ] Use matrix strategies for parallel builds
- [ ] Include proper permissions blocks
- [ ] Use environment variables for secrets

### 🛠️ **Advanced Validation**

#### **actionlint Integration:**
If `actionlint` is installed:
```bash
brew install actionlint
```

The validation script will automatically use actionlint for advanced GitHub Actions validation.

#### **GitHub CLI Integration:**
If `gh` CLI is installed and authenticated:
```bash
brew install gh
gh auth login
```

Additional validation capabilities become available.

### 📈 **Validation Metrics**

#### **Workflow Coverage:**
- **CI/Build Workflows**: Automated build and test pipelines
- **Release/Deploy Workflows**: Deployment automation
- **Security Workflows**: Security scanning and analysis
- **Validation Workflows**: Configuration and dependency validation

#### **Quality Gates:**
- All workflows must pass YAML syntax validation
- All workflows must pass GitHub Actions structure validation
- Security issues must be resolved before deployment
- Performance optimizations are recommended but not required

### 🚀 **Usage Examples**

#### **Validate All Workflows:**
```bash
./scripts/validate-github-actions.sh
```

#### **Setup Git Hooks:**
```bash
./scripts/setup-github-hooks.sh
```

#### **Validate Single Workflow:**
```bash
python3 -c "
import yaml
with open('.github/workflows/ci.yml', 'r') as f:
    yaml.safe_load(f)
print('Workflow is valid')
"
```

### 🔄 **Continuous Integration**

The validation system is integrated into:
- **Pre-commit hooks** - Automatic validation on commit
- **Pre-push hooks** - Additional validation before push
- **GitHub Actions workflows** - Validation pipeline runs on every push/PR
- **Manual validation** - On-demand validation for development

### 📚 **Additional Resources**

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [actionlint Documentation](https://rhysd.github.io/actionlint/)
- [GitHub CLI Documentation](https://cli.github.com/)
- [YAML Syntax Guide](https://yaml.org/spec/1.2/spec.html)

---

**This validation system ensures high-quality, secure, and optimized GitHub Actions workflows for the Crown & Barrel iOS app.**
