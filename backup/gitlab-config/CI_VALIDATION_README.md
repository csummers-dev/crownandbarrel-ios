# GitLab CI/CD Validation and Testing Guide

## 🎯 **Overview**

This guide explains how to validate and test GitLab CI/CD configurations before pushing to avoid pipeline creation errors.

## 🚨 **Common GitLab CI Errors and Solutions**

### **Error: "before_script config should be a string or a nested array of strings up to 10 levels deep"**

This error occurs when the `before_script` configuration doesn't follow GitLab CI YAML syntax requirements.

#### **Root Causes:**
1. **Inline comments within arrays**: Comments like `# Set up simulator` inside `before_script` arrays
2. **Complex variable substitution**: Unquoted variables that cause parsing issues
3. **Multiline scripts**: Improper use of `|` (pipe) character in script blocks
4. **Invalid YAML structure**: Arrays containing non-string elements

#### **Solutions Applied:**
- ✅ Removed all inline comments from `before_script` arrays
- ✅ Simplified variable usage and hardcoded simulator names
- ✅ Converted all multiline scripts to single-line commands
- ✅ Ensured all script items are strings

## 🔧 **Validation Tools**

### **1. Automated Validation Script**

Run the comprehensive validation script before pushing:

```bash
./scripts/validate-gitlab-ci.sh
```

**What it validates:**
- ✅ YAML syntax correctness
- ✅ GitLab CI structure compliance
- ✅ `before_script` and `script` configurations
- ✅ Job naming conventions
- ✅ Common configuration issues

### **2. Git Hooks (Automatic Validation)**

Git hooks are automatically installed and will run validation on:
- **Pre-commit**: Validates files before each commit
- **Pre-push**: Additional validation before pushing to remote

**To bypass hooks temporarily:**
```bash
git commit --no-verify  # Skip pre-commit validation
git push --no-verify    # Skip pre-push validation
```

### **3. Manual Validation Commands**

#### **Basic YAML Syntax Check:**
```bash
python3 -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml'))"
```

#### **GitLab CLI Validation (if available):**
```bash
# Install GitLab CLI
brew install glab

# Validate CI configuration
glab ci lint
```

## 📋 **Pre-Push Checklist**

Before pushing changes to GitLab CI configuration:

### **✅ Required Checks:**
1. **Run validation script**: `./scripts/validate-gitlab-ci.sh`
2. **Check YAML syntax**: Ensure no syntax errors
3. **Validate script arrays**: All items must be strings
4. **Remove inline comments**: No comments within arrays
5. **Test locally**: Run basic commands if possible

### **✅ Best Practices:**
- Use simple, single-line commands in `script` arrays
- Avoid complex variable substitution in script arrays
- Keep `before_script` configurations simple and reliable
- Use quoted strings for variables when possible
- Test configuration changes in feature branches first

## 🛠️ **Troubleshooting**

### **If Validation Fails:**

1. **Check YAML syntax:**
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('.gitlab-ci.yml'))"
   ```

2. **Look for common issues:**
   - Inline comments in arrays
   - Unquoted variables
   - Multiline scripts with `|`
   - Non-string items in script arrays

3. **Simplify problematic sections:**
   - Replace complex commands with simple ones
   - Remove unnecessary variable substitution
   - Use hardcoded values instead of variables when possible

### **If Pipeline Still Fails:**

1. **Check GitLab CI documentation**: [GitLab CI/CD YAML syntax reference](https://docs.gitlab.com/ci/yaml/)
2. **Validate with GitLab CLI**: `glab ci lint`
3. **Test in GitLab UI**: Use the CI Lint tool in GitLab
4. **Simplify configuration**: Remove complex features temporarily

## 📁 **File Structure**

```
scripts/
├── validate-gitlab-ci.sh      # Comprehensive CI validation
├── setup-git-hooks.sh         # Git hooks installation
└── generate-app-icons.sh      # App icon generation

.git/hooks/
├── pre-commit                 # Pre-commit validation hook
└── pre-push                   # Pre-push validation hook

.gitlab-ci.yml                 # GitLab CI configuration
CI_VALIDATION_README.md        # This documentation
```

## 🚀 **Quick Start**

### **1. Initial Setup:**
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Set up git hooks
./scripts/setup-git-hooks.sh
```

### **2. Before Each Push:**
```bash
# Validate CI configuration
./scripts/validate-gitlab-ci.sh

# If validation passes, push
git push origin feature/your-branch
```

### **3. If You Encounter Issues:**
```bash
# Check what's wrong
./scripts/validate-gitlab-ci.sh

# Fix issues and re-validate
# ... make changes ...
./scripts/validate-gitlab-ci.sh

# Commit and push
git add .gitlab-ci.yml
git commit -m "Fix GitLab CI configuration"
git push
```

## 📚 **Additional Resources**

- [GitLab CI/CD YAML syntax reference](https://docs.gitlab.com/ci/yaml/)
- [GitLab CI/CD best practices](https://docs.gitlab.com/ee/ci/pipelines/pipeline_efficiency.html)
- [GitLab CLI documentation](https://glab.readthedocs.io/)

## 🎯 **Success Criteria**

Your GitLab CI configuration is ready when:
- ✅ Validation script passes without errors
- ✅ YAML syntax is valid
- ✅ All script arrays contain only strings
- ✅ No inline comments in arrays
- ✅ Pipeline creates successfully in GitLab

---

**With these tools and practices, you can avoid GitLab CI pipeline creation errors and ensure reliable CI/CD workflows!** 🎉
