# Phase 2A: Code Signing & Distribution Setup
## TODO List - Crown & Barrel TestFlight Preparation

### 🎯 **Phase Objective**
Configure proper code signing and distribution certificates for TestFlight deployment.

---

## ✅ **TODO List**

### **2A.1: Apple Developer Account Verification** 
**Priority**: 🔴 Critical | **Owner**: User | **Time**: 15 min

#### **Tasks to Complete**:
- [ ] Log into [Apple Developer Portal](https://developer.apple.com/account)
- [ ] Verify active Apple Developer Program membership status
- [ ] Confirm account has distribution capabilities enabled
- [ ] Locate and document your Team ID (10-character alphanumeric)
- [ ] Note account type (Individual or Organization)
- [ ] Check membership expiration date
- [ ] Screenshot Team ID for reference

#### **Information to Record**:
- **Team ID**: `_________________` (replace ABC123DEFG placeholder)
- **Account Type**: Individual / Organization
- **Membership Expires**: `_________________`
- **Distribution Enabled**: Yes / No

#### **Success Criteria**:
- ✅ Active Apple Developer Program membership confirmed
- ✅ Team ID documented and ready for configuration
- ✅ Distribution capabilities verified

---

### **2A.2: App ID Registration**
**Priority**: 🔴 Critical | **Owner**: User | **Time**: 10 min

#### **Tasks to Complete**:
- [ ] Navigate to "Certificates, Identifiers & Profiles" in Developer Portal
- [ ] Go to "Identifiers" section
- [ ] Check if `com.crownandbarrel.app` already exists
- [ ] If not exists: Click "+" to create new App ID
- [ ] Configure App ID details:
  - [ ] **Bundle ID**: `com.crownandbarrel.app` (Explicit)
  - [ ] **Description**: "Crown & Barrel - Luxury Watch Collection"
  - [ ] **Platform**: iOS, macOS (for Mac Catalyst if desired)
- [ ] Review and enable required capabilities:
  - [ ] **Core Data** ✅ (for watch collection storage)
  - [ ] **Background Processing** ❓ (for future features)
  - [ ] **Push Notifications** ❓ (for future features)
  - [ ] **iCloud** ❓ (for future cloud backup)
- [ ] Save and confirm App ID creation

#### **Capability Decision Guide**:
- **Core Data**: ✅ Required (Crown & Barrel uses Core Data)
- **Background Processing**: ❓ Optional (future feature consideration)
- **Push Notifications**: ❓ Optional (no current usage)
- **iCloud**: ❓ Optional (future cloud backup feature)

#### **Success Criteria**:
- ✅ App ID `com.crownandbarrel.app` registered and active
- ✅ Required capabilities enabled
- ✅ App ID configuration matches project settings

---

### **2A.3: Distribution Certificate Creation**
**Priority**: 🔴 Critical | **Owner**: User | **Time**: 20 min

#### **Tasks to Complete**:
- [ ] Navigate to "Certificates" section in Developer Portal
- [ ] Click "+" to create new certificate
- [ ] Select "iOS Distribution" certificate type
- [ ] Generate Certificate Signing Request (CSR):
  - [ ] Open Keychain Access on Mac
  - [ ] Keychain Access → Certificate Assistant → Request Certificate from CA
  - [ ] Enter your email address
  - [ ] Enter "Crown & Barrel Distribution" as Common Name
  - [ ] Select "Saved to disk" and "Let me specify key pair information"
  - [ ] Save CSR file to Desktop
- [ ] Upload CSR file to Apple Developer Portal
- [ ] Download completed distribution certificate
- [ ] Double-click certificate to install in Keychain
- [ ] Verify "iPhone Distribution" identity appears in Keychain Access
- [ ] Export certificate as .p12 file with secure password (for GitHub Actions)

#### **Keychain Verification**:
After installation, verify in Keychain Access:
- [ ] Certificate appears under "My Certificates"
- [ ] Shows "iPhone Distribution: [Your Name/Organization]"
- [ ] Has valid expiration date (1 year from creation)
- [ ] Private key is associated with certificate

#### **Success Criteria**:
- ✅ iOS Distribution certificate created and downloaded
- ✅ Certificate installed in Keychain Access
- ✅ "iPhone Distribution" identity available for code signing
- ✅ Certificate exported as .p12 for automation

---

### **2A.4: Provisioning Profile Creation**
**Priority**: 🔴 Critical | **Owner**: User | **Time**: 15 min

#### **Tasks to Complete**:
- [ ] Navigate to "Profiles" section in Developer Portal
- [ ] Click "+" to create new provisioning profile
- [ ] Select "App Store" distribution type
- [ ] Configure profile settings:
  - [ ] **App ID**: Select `com.crownandbarrel.app`
  - [ ] **Certificate**: Select your iOS Distribution certificate
  - [ ] **Profile Name**: "Crown & Barrel App Store Distribution"
- [ ] Generate and download provisioning profile
- [ ] Double-click profile to install in Xcode
- [ ] Verify profile appears in Xcode → Settings → Accounts → Team → Manage Certificates

#### **Xcode Verification**:
- [ ] Open Xcode → Settings → Accounts
- [ ] Select your Apple ID and Team
- [ ] Click "Manage Certificates"
- [ ] Verify "iOS Distribution" certificate appears
- [ ] Check "Download Manual Profiles" if needed
- [ ] Confirm profile is available for project

#### **Success Criteria**:
- ✅ App Store distribution provisioning profile created
- ✅ Profile installed and available in Xcode
- ✅ Profile linked to correct App ID and certificate

---

### **2A.5: Update Export Options for TestFlight**
**Priority**: 🔴 Critical | **Owner**: AI Assistant | **Time**: 10 min

#### **Tasks to Complete**:
- [ ] Create `exportOptions-testflight.plist` with proper TestFlight settings
- [ ] Update existing `exportOptions.plist` with correct Team ID
- [ ] Configure signing method and provisioning profiles
- [ ] Set up symbol upload and optimization settings
- [ ] Test export options with local archive
- [ ] Validate IPA generation works correctly

#### **Configuration Requirements**:
- **Method**: `app-store` (for TestFlight distribution)
- **Team ID**: Your actual Team ID from Task 2A.1
- **Signing Style**: `automatic` (recommended) or `manual`
- **Upload Symbols**: `true` (for crash reporting)
- **Strip Swift Symbols**: `true` (for App Store compliance)

#### **Validation Steps**:
- [ ] Test archive creation with new export options
- [ ] Verify IPA file is generated correctly
- [ ] Check IPA file size and contents
- [ ] Validate signing and provisioning in IPA

#### **Success Criteria**:
- ✅ TestFlight-optimized export options created
- ✅ Export configuration tested and validated
- ✅ IPA generation working correctly

---

## 🎯 **Phase 2A Completion Checklist**

### **Before Moving to Phase 2B**:
- [ ] ✅ Apple Developer account verified with Team ID documented
- [ ] ✅ App ID `com.crownandbarrel.app` registered with required capabilities
- [ ] ✅ iOS Distribution certificate created and installed
- [ ] ✅ App Store provisioning profile created and installed
- [ ] ✅ Export options updated and tested
- [ ] ✅ Local signed archive and IPA generation successful

### **Information Collected**:
- **Team ID**: `_________________`
- **Certificate Name**: `_________________`
- **Profile Name**: `_________________`
- **Bundle ID**: `com.crownandbarrel.app` ✅

### **Files Created/Updated**:
- [ ] `exportOptions-testflight.plist` ✅
- [ ] Distribution certificate (.p12 backup) ✅
- [ ] Provisioning profile (.mobileprovision backup) ✅

---

## 🚀 **Ready for Phase 2B?**

Once all Phase 2A tasks are complete, you'll be ready to proceed to **Phase 2B: Build Pipeline Configuration**, where we'll:
- Configure GitHub Secrets with your certificates
- Update the release workflow for automated TestFlight builds
- Set up automated upload to App Store Connect (optional)

**Estimated Phase 2A Duration**: 1-2 hours (depending on familiarity with Apple Developer Portal)

**Next Phase Preview**: Phase 2B will be largely automated once you provide the certificates and Team ID information.
