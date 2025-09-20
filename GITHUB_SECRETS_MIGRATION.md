# GitHub Secrets Migration Guide
## Crown & Barrel - GitLab CI Variables to GitHub Secrets

### 🎯 **Overview**

This guide provides step-by-step instructions for migrating GitLab CI variables to GitHub Secrets for the Crown & Barrel iOS app.

### 📋 **Secrets Migration Checklist**

#### **Required GitHub Secrets**
Copy these secrets to your GitHub repository: **Settings → Secrets and variables → Actions → Repository secrets**

| GitHub Secret Name | GitLab Variable | Description | Masked | Required |
|-------------------|-----------------|-------------|---------|----------|
| `APPLE_ID` | `APPLE_ID` | Apple Developer Account Email | ❌ | ✅ |
| `APPLE_ID_PASSWORD` | `APPLE_ID_PASSWORD` | Apple ID App-Specific Password | ✅ | ✅ |
| `FASTLANE_USER` | `FASTLANE_USER` | Fastlane Username | ❌ | ✅ |
| `FASTLANE_PASSWORD` | `FASTLANE_PASSWORD` | Fastlane Password | ✅ | ✅ |
| `FASTLANE_SESSION` | `FASTLANE_SESSION` | Fastlane Session Token | ✅ | ✅ |
| `TEAM_ID` | `TEAM_ID` | Apple Developer Team ID | ❌ | ✅ |
| `BUNDLE_ID` | `BUNDLE_ID` | iOS App Bundle Identifier | ❌ | ✅ |
| `MATCH_PASSWORD` | `MATCH_PASSWORD` | Match Passphrase | ✅ | ✅ |
| `CERTIFICATE_P12` | `CERTIFICATE_P12` | Code Signing Certificate | ❌ | ✅ |
| `CERTIFICATE_PASSWORD` | `CERTIFICATE_PASSWORD` | Certificate Password | ✅ | ✅ |

### 🔐 **Step-by-Step Migration**

#### **1. Access GitHub Repository Settings**
1. Navigate to: `https://github.com/csummers-dev/crownandbarrel-ios`
2. Click **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**

#### **2. Add Repository Secrets**
For each secret in the table above:

1. Click **New repository secret**
2. Enter the **Name** (GitHub Secret Name from table)
3. Enter the **Secret** (value from current GitLab CI variables)
4. Click **Add secret**

#### **3. Verify Secrets**
After adding all secrets, verify they appear in the repository secrets list:
- ✅ `APPLE_ID`
- ✅ `APPLE_ID_PASSWORD`
- ✅ `FASTLANE_USER`
- ✅ `FASTLANE_PASSWORD`
- ✅ `FASTLANE_SESSION`
- ✅ `TEAM_ID`
- ✅ `BUNDLE_ID`
- ✅ `MATCH_PASSWORD`
- ✅ `CERTIFICATE_P12`
- ✅ `CERTIFICATE_PASSWORD`

### 📝 **Current GitLab CI Variables (Reference)**

```bash
# Apple Developer Account
APPLE_ID=corywatch@icloud.com
APPLE_ID_PASSWORD=tqzc-dyao-ybdw-qtlh
FASTLANE_USER=corywatch@icloud.com
FASTLANE_PASSWORD=tqzc-dyao-ybdw-qtlh
FASTLANE_SESSION=M1Jsai/ZKg4deGZ3PytxENXVUIoYFRrSXVsbEO3vGn9TznEV38ud9PW3nJA+DI82nRLmLrj62QQ4vUk3Z3vuQw==

# Code Signing
TEAM_ID=G7Z5DDPMSL
BUNDLE_ID=com.crownandbarrel.app
MATCH_PASSWORD=HyanlGM0C/o2O4hZUl+tUBKTa+xpgw3nF5w1fbyBhYQ=

# Certificates
CERTIFICATE_P12=[FILE - needs to be uploaded as secret]
CERTIFICATE_PASSWORD=[MASKED]
```

### 🔒 **Security Best Practices**

#### **Secret Management**
- ✅ **Use App-Specific Passwords**: Never use your main Apple ID password
- ✅ **Rotate Secrets Regularly**: Update secrets periodically
- ✅ **Limit Access**: Only repository maintainers should have access
- ✅ **Audit Access**: Regularly review who has access to secrets

#### **GitHub Secrets vs GitLab Variables**
- **GitHub Secrets**: Automatically masked in logs, more secure
- **GitLab Variables**: Can be masked or unmasked, less secure by default
- **Migration Benefit**: Enhanced security with GitHub Secrets

### 🚀 **GitHub Actions Usage**

In GitHub Actions workflows, secrets are accessed using:

```yaml
env:
  APPLE_ID: ${{ secrets.APPLE_ID }}
  APPLE_ID_PASSWORD: ${{ secrets.APPLE_ID_PASSWORD }}
  FASTLANE_USER: ${{ secrets.FASTLANE_USER }}
  FASTLANE_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}
  FASTLANE_SESSION: ${{ secrets.FASTLANE_SESSION }}
  TEAM_ID: ${{ secrets.TEAM_ID }}
  BUNDLE_ID: ${{ secrets.BUNDLE_ID }}
  MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
  CERTIFICATE_P12: ${{ secrets.CERTIFICATE_P12 }}
  CERTIFICATE_PASSWORD: ${{ secrets.CERTIFICATE_PASSWORD }}
```

### 📋 **Migration Verification**

#### **After Adding All Secrets**
1. **Verify Count**: Ensure 10 secrets are listed
2. **Test Access**: Run a test workflow to verify secrets are accessible
3. **Check Logs**: Ensure secrets are masked in workflow logs
4. **Validate Values**: Verify secret values match GitLab CI variables

#### **Common Issues**
- **Missing Secrets**: Ensure all 10 secrets are added
- **Incorrect Names**: Verify secret names match GitHub Actions workflow
- **Invalid Values**: Double-check secret values from GitLab CI
- **Access Permissions**: Ensure secrets are accessible to workflows

### 🔄 **Rollback Plan**

If migration issues occur:
1. **Keep GitLab CI Variables**: Don't delete GitLab variables until GitHub Actions is verified
2. **Test Thoroughly**: Run multiple test workflows before removing GitLab variables
3. **Backup Values**: Keep a secure backup of all secret values
4. **Document Changes**: Track all changes made during migration

### 📞 **Support**

If you encounter issues:
1. **Check GitHub Documentation**: [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
2. **Verify Repository Access**: Ensure you have admin access to the repository
3. **Check Secret Names**: Verify secret names match workflow requirements
4. **Test Workflow**: Run a simple test workflow to verify secrets work

---

**Migration Complete**: Once all secrets are added, GitHub Actions workflows can access them using `${{ secrets.SECRET_NAME }}` syntax.
