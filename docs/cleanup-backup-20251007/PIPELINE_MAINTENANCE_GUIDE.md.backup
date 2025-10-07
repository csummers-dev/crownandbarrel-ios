# Pipeline Maintenance Guide

This guide ensures consistent maintenance across all CI/CD workflows and prevents issues like missed updates during pipeline fixes.

## Overview

The CrownAndBarrel iOS project has **8 GitHub Actions workflows** that require consistent maintenance. This guide provides systematic procedures to ensure all workflows are updated together and no components are missed during fixes.

## Workflow Inventory

### Complete List of Workflows

| Workflow File | Purpose | Key Components |
|---------------|---------|----------------|
| `.github/workflows/ci.yml` | Main CI/CD pipeline | Build, test, lint, deploy |
| `.github/workflows/security.yml` | Security scanning | CodeQL, dependency scan, secret scan |
| `.github/workflows/validate.yml` | Code validation | SwiftLint, build performance |
| `.github/workflows/performance-monitor.yml` | Performance monitoring | Build metrics, test timing |
| `.github/workflows/ios-ci.yml` | iOS-specific CI | Unit tests, UI tests |
| `.github/workflows/release.yml` | Release management | TestFlight, App Store deployment |
| `.github/workflows/dependency-update.yml` | Dependency updates | Dependabot automation |
| `.github/workflows/security-audit.yml` | Security auditing | Additional security checks |

## Maintenance Procedures

### 1. Before Making Any Pipeline Changes

**Always run this checklist:**

```bash
# 1. List all workflow files
find .github/workflows -name "*.yml" -type f

# 2. Verify workflow syntax
for file in .github/workflows/*.yml; do
  echo "Checking $file..."
  python -c "import yaml; yaml.safe_load(open('$file'))" || echo "❌ $file has syntax errors"
done

# 3. Check for common patterns that need updating
grep -r "xcodegen" .github/workflows/
grep -r "xcodebuild" .github/workflows/
grep -r "destination.*generic" .github/workflows/
```

### 2. Systematic Update Process

When fixing pipeline issues, **ALWAYS** follow this process:

#### Step 1: Identify All Affected Workflows
```bash
# Search for the problematic pattern across ALL workflows
grep -r "PROBLEM_PATTERN" .github/workflows/
```

#### Step 2: Create Update Checklist
Create a checklist for each workflow file:
- [ ] `.github/workflows/ci.yml`
- [ ] `.github/workflows/security.yml` 
- [ ] `.github/workflows/validate.yml`
- [ ] `.github/workflows/performance-monitor.yml`
- [ ] `.github/workflows/ios-ci.yml`
- [ ] `.github/workflows/release.yml`
- [ ] `.github/workflows/dependency-update.yml`
- [ ] `.github/workflows/security-audit.yml`

#### Step 3: Apply Changes Systematically
1. **Update each workflow file** using the same fix
2. **Test locally** if possible
3. **Commit each workflow separately** with descriptive messages
4. **Verify all workflows** before pushing

#### Step 4: Final Verification
```bash
# Verify all workflows have been updated
grep -r "OLD_PATTERN" .github/workflows/ || echo "✅ All workflows updated"

# Check for consistency
grep -r "NEW_PATTERN" .github/workflows/ | wc -l
```

### 3. Common Patterns That Need Consistent Updates

#### XcodeGen Installation
**Pattern to search for:** `xcodegen.zip` or `xcodegen generate`
**Files typically affected:** All workflows that generate Xcode projects

#### Simulator Destinations
**Pattern to search for:** `generic/platform=iOS Simulator`
**Files typically affected:** All workflows that build or test iOS apps

#### Build Settings
**Pattern to search for:** `IPHONEOS_DEPLOYMENT_TARGET`
**Files typically affected:** All workflows that compile iOS code

#### Homebrew Installation
**Pattern to search for:** `brew install`
**Files typically affected:** All workflows that install dependencies

### 4. Quality Assurance Checklist

Before committing pipeline changes:

- [ ] **All 8 workflow files reviewed**
- [ ] **Same fix applied consistently** across all relevant workflows
- [ ] **No workflow left with old pattern**
- [ ] **Local testing completed** (if applicable)
- [ ] **Commit messages are descriptive** and reference all affected files
- [ ] **Pre-push validation passes**

### 5. Emergency Fix Procedures

For urgent pipeline fixes:

1. **Stop and assess** - Don't rush the fix
2. **Create the checklist** first
3. **Apply systematically** - don't skip workflows
4. **Test incrementally** - commit each workflow separately
5. **Verify completeness** before marking as resolved

## Historical Issues and Lessons Learned

### Issue: CodeQL Build Destination Missed (2025-09-20)

**What happened:** The security workflow's CodeQL build step was missed during simulator destination fixes.

**Root cause:** Incomplete systematic review - only main CI workflows were updated.

**Prevention:** Always search for ALL patterns across ALL workflow files before making changes.

**Command to prevent this:**
```bash
grep -r "destination.*generic" .github/workflows/
```

### Issue: XcodeGen PATH Issues (2025-09-20)

**What happened:** Some workflows had separate install/generate steps causing PATH issues.

**Root cause:** Inconsistent installation patterns across workflows.

**Prevention:** Use the same installation pattern across all workflows.

### Issue: Homebrew Architecture Conflicts (2025-09-20)

**What happened:** ARM64/x86_64 conflicts in dependency installation.

**Root cause:** Not all workflows used the robust 3-tier installation strategy.

**Prevention:** Apply the same installation strategy to all workflows.

## Automation Scripts

### Workflow Consistency Checker

Create this script to verify workflow consistency:

```bash
#!/bin/bash
# workflow-consistency-check.sh

echo "🔍 Checking workflow consistency..."

# Check for common patterns that should be consistent
PATTERNS=(
    "xcodegen.zip"
    "generic/platform=iOS Simulator"
    "IPHONEOS_DEPLOYMENT_TARGET"
    "brew install"
)

for pattern in "${PATTERNS[@]}"; do
    echo "Checking pattern: $pattern"
    matches=$(grep -r "$pattern" .github/workflows/ | wc -l)
    echo "Found $matches occurrences"
    
    if [ $matches -gt 0 ]; then
        echo "Files with '$pattern':"
        grep -r "$pattern" .github/workflows/ | cut -d: -f1 | sort | uniq
    fi
    echo "---"
done
```

### Workflow Update Template

When making systematic updates, use this template:

```markdown
## Pipeline Update: [ISSUE_NAME]

### Affected Workflows
- [ ] `.github/workflows/ci.yml`
- [ ] `.github/workflows/security.yml`
- [ ] `.github/workflows/validate.yml`
- [ ] `.github/workflows/performance-monitor.yml`
- [ ] `.github/workflows/ios-ci.yml`
- [ ] `.github/workflows/release.yml`
- [ ] `.github/workflows/dependency-update.yml`
- [ ] `.github/workflows/security-audit.yml`

### Change Description
[Describe what needs to be changed and why]

### Search Pattern
[The grep pattern used to find affected files]

### Verification Command
[Command to verify all workflows were updated]

### Testing
- [ ] Local testing completed
- [ ] All workflows updated consistently
- [ ] No old patterns remaining
```

## Best Practices

### 1. Never Update Workflows Individually
Always search for patterns across ALL workflows before making changes.

### 2. Use Descriptive Commit Messages
Include all affected workflow files in commit messages:
```
Fix simulator destinations in ci.yml, security.yml, validate.yml, performance-monitor.yml
```

### 3. Test Incrementally
Commit each workflow separately to make debugging easier.

### 4. Document Changes
Update this maintenance guide when new patterns or workflows are added.

### 5. Regular Audits
Run the consistency checker regularly to catch drift.

## Related Documentation

- [CI/CD Troubleshooting Guide](CI_CD_TROUBLESHOOTING.md)
- [GitHub Actions Workflows](.github/ACTIONS_README.md)
- [Migration Summary](../MIGRATION_COMPLETE.md)

## Support

For pipeline maintenance questions:

1. Check this maintenance guide first
2. Run the consistency checker script
3. Review historical issues for similar problems
4. Follow the systematic update process
5. Document any new patterns or workflows discovered
