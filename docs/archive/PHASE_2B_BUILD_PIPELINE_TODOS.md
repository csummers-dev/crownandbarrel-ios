# Phase 2B: Build Pipeline Configuration
## TODO List - Crown & Barrel TestFlight Preparation

### 🎯 **Phase Objective**
Configure automated build pipeline for consistent TestFlight deployments using your certificates from Phase 2A.

**Prerequisites**: Phase 2A must be completed with certificates and Team ID available.

---

## ✅ **TODO List**

### **2B.1: GitHub Secrets Configuration**
**Priority**: 🔴 Critical | **Owner**: User | **Time**: 20 min

#### **Preparation Steps**:
- [ ] Gather certificates and information from Phase 2A:
  - [ ] Distribution certificate (.p12 file)
  - [ ] Certificate password
  - [ ] Provisioning profile (.mobileprovision file)
  - [ ] Team ID from Apple Developer account

#### **Base64 Encoding** (Required for GitHub Secrets):
- [ ] **Encode Distribution Certificate**:
  ```bash
  base64 -i /path/to/distribution_certificate.p12 | pbcopy
  ```
  - [ ] Copy output and save as `APPLE_CERTIFICATE_P12` secret

- [ ] **Encode Provisioning Profile**:
  ```bash
  base64 -i /path/to/Crown_Barrel_App_Store_Distribution.mobileprovision | pbcopy
  ```
  - [ ] Copy output and save as `APPLE_PROVISIONING_PROFILE` secret

#### **GitHub Repository Secrets to Configure**:
Navigate to GitHub Repository → Settings → Secrets and variables → Actions

**Required Secrets**:
- [ ] `APPLE_TEAM_ID`: Your Team ID from Phase 2A (e.g., `ABCD123456`)
- [ ] `APPLE_CERTIFICATE_P12`: Base64 encoded distribution certificate
- [ ] `APPLE_CERTIFICATE_PASSWORD`: Password for the .p12 certificate
- [ ] `APPLE_PROVISIONING_PROFILE`: Base64 encoded provisioning profile

**Optional Secrets** (for automated upload):
- [ ] `APP_STORE_CONNECT_API_KEY_ID`: API Key ID for automated uploads
- [ ] `APP_STORE_CONNECT_API_ISSUER_ID`: Issuer ID for API authentication
- [ ] `APP_STORE_CONNECT_API_KEY`: Base64 encoded API private key (.p8 file)
- [ ] `APPLE_ID`: Your Apple ID email (for altool uploads)
- [ ] `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password for altool

#### **Security Best Practices**:
- [ ] Use strong, unique password for certificate
- [ ] Store certificate backups securely offline
- [ ] Document secret names and purposes
- [ ] Test secret access in GitHub Actions (dry run)

#### **Success Criteria**:
- ✅ All required secrets configured in GitHub repository
- ✅ Secrets properly base64 encoded and formatted
- ✅ Certificate and profile information accessible to workflows

---

### **2B.2: Create TestFlight Export Options**
**Priority**: 🔴 Critical | **Owner**: AI Assistant | **Time**: 15 min

#### **Tasks to Complete**:
- [ ] Create `exportOptions-testflight.plist` with TestFlight-specific settings
- [ ] Create `exportOptions-appstore.plist` for future App Store distribution
- [ ] Update existing `exportOptions.plist` with correct Team ID
- [ ] Configure signing method and provisioning profiles
- [ ] Set up symbol upload and optimization settings

#### **TestFlight Export Configuration**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>upload</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.crownandbarrel.app</key>
        <string>Crown & Barrel App Store Distribution</string>
    </dict>
</dict>
</plist>
```

#### **Success Criteria**:
- ✅ TestFlight export options created and configured
- ✅ Team ID properly set in export options
- ✅ Provisioning profile names match Apple Developer Portal

---

### **2B.3: Update Release Workflow for TestFlight**
**Priority**: 🔴 Critical | **Owner**: AI Assistant | **Time**: 30 min

#### **Tasks to Complete**:
- [ ] Update `.github/workflows/release.yml` with proper secret integration
- [ ] Configure certificate and profile installation in CI
- [ ] Add keychain setup for code signing
- [ ] Update archive commands with correct Team ID and signing
- [ ] Add IPA export step with TestFlight export options
- [ ] Implement upload to App Store Connect (optional automated step)
- [ ] Add comprehensive error handling and validation
- [ ] Configure artifact upload for debugging

#### **Workflow Enhancements**:
- [ ] **Certificate Installation**: Secure keychain setup in CI
- [ ] **Profile Installation**: Automatic provisioning profile installation
- [ ] **Archive Creation**: Signed archive with distribution certificate
- [ ] **IPA Export**: TestFlight-optimized IPA generation
- [ ] **Upload Automation**: Optional automated upload to App Store Connect
- [ ] **Validation**: Build validation and error reporting
- [ ] **Cleanup**: Secure cleanup of certificates and keys

#### **Security Considerations**:
- [ ] Temporary keychain creation for CI security
- [ ] Secure secret handling and cleanup
- [ ] Certificate and key protection during build
- [ ] No secret logging or exposure

#### **Success Criteria**:
- ✅ Release workflow updated with proper code signing
- ✅ GitHub Actions can create signed archives
- ✅ IPA export working with TestFlight options
- ✅ Optional automated upload configured

---

### **2B.4: Local Build Testing**
**Priority**: 🟡 High | **Owner**: AI Assistant + User | **Time**: 20 min

#### **Tasks to Complete**:
- [ ] Test local archive creation with distribution certificate
- [ ] Verify IPA export with TestFlight export options
- [ ] Validate IPA structure and signing
- [ ] Test installation on physical device (if available)
- [ ] Run comprehensive app functionality tests
- [ ] Verify all luxury themes and haptic feedback work correctly

#### **Local Testing Commands**:
```bash
# Create signed archive
xcodebuild archive \
  -project "CrownAndBarrel.xcodeproj" \
  -scheme "CrownAndBarrel" \
  -configuration "Release" \
  -destination "generic/platform=iOS" \
  -archivePath "CrownAndBarrel-TestFlight.xcarchive" \
  CODE_SIGNING_ALLOWED=YES \
  DEVELOPMENT_TEAM="YOUR_TEAM_ID" \
  CODE_SIGN_IDENTITY="iPhone Distribution"

# Export for TestFlight
xcodebuild -exportArchive \
  -archivePath "CrownAndBarrel-TestFlight.xcarchive" \
  -exportPath "CrownAndBarrel-TestFlight" \
  -exportOptionsPlist "exportOptions-testflight.plist"

# Validate IPA (optional)
xcrun altool --validate-app \
  --file "CrownAndBarrel-TestFlight/CrownAndBarrel.ipa" \
  --type ios \
  --username "YOUR_APPLE_ID" \
  --password "APP_SPECIFIC_PASSWORD"
```

#### **Validation Checklist**:
- [ ] Archive created without errors
- [ ] IPA file generated successfully
- [ ] IPA file size reasonable (< 200MB expected for Crown & Barrel)
- [ ] Signing identity correct in archive
- [ ] Provisioning profile embedded correctly

#### **Success Criteria**:
- ✅ Local signed archive creation successful
- ✅ TestFlight IPA export working
- ✅ IPA validation passes (if tested)
- ✅ Ready for automated pipeline

---

### **2B.5: GitHub Actions Testing**
**Priority**: 🟡 High | **Owner**: AI Assistant | **Time**: 15 min

#### **Tasks to Complete**:
- [ ] Test updated release workflow with GitHub Actions
- [ ] Verify secret integration works correctly
- [ ] Validate certificate and profile installation in CI
- [ ] Confirm signed archive creation in GitHub Actions
- [ ] Test IPA export in CI environment
- [ ] Validate artifact upload and storage

#### **GitHub Actions Test Plan**:
- [ ] **Trigger Test Build**: Push to release branch or manual trigger
- [ ] **Monitor Workflow**: Watch GitHub Actions execution
- [ ] **Verify Steps**: Confirm each step completes successfully
- [ ] **Check Artifacts**: Download and verify generated IPA
- [ ] **Validate Signing**: Confirm proper code signing in CI

#### **Troubleshooting Checklist**:
- [ ] Secrets properly configured and accessible
- [ ] Certificate password correct
- [ ] Team ID matches Apple Developer account
- [ ] Provisioning profile valid and not expired
- [ ] Xcode version compatible with certificates

#### **Success Criteria**:
- ✅ GitHub Actions successfully creates signed archive
- ✅ IPA export completes in CI environment
- ✅ Artifacts properly uploaded and accessible
- ✅ No code signing errors in automated pipeline

---

## 🎯 **Phase 2B Completion Checklist**

### **Critical Deliverables**:
- [ ] ✅ GitHub Secrets properly configured with certificates
- [ ] ✅ TestFlight export options created and tested
- [ ] ✅ Release workflow updated for code signing
- [ ] ✅ Local build testing successful
- [ ] ✅ GitHub Actions pipeline validated

### **Files Created/Updated**:
- [ ] `exportOptions-testflight.plist` ✅
- [ ] `exportOptions-appstore.plist` ✅ (for future)
- [ ] `.github/workflows/release.yml` ✅ (updated)
- [ ] GitHub repository secrets ✅ (configured)

### **Validation Results**:
- [ ] Local archive: SUCCESS / FAILED
- [ ] Local IPA export: SUCCESS / FAILED
- [ ] GitHub Actions build: SUCCESS / FAILED
- [ ] Code signing verification: SUCCESS / FAILED

---

## 🚀 **Ready for Phase 3?**

Once Phase 2B is complete, you'll have:
- ✅ **Working signed builds** both locally and in CI
- ✅ **TestFlight-ready IPA files** that can be uploaded
- ✅ **Automated build pipeline** for consistent releases
- ✅ **Proper code signing** for App Store distribution

**Next Phase**: Phase 3 will focus on setting up the App Store Connect app record and configuring all the metadata and information needed for TestFlight.

**Estimated Phase 2B Duration**: 1-2 hours (mostly automated after secrets configuration)

**Critical Success Factor**: Accurate Team ID and properly exported certificates from Phase 2A.
