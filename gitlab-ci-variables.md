# GitLab CI/CD Variables Configuration

Add these variables to your GitLab project:
**Settings → CI/CD → Variables**

## Required Variables

| Variable | Value | Type | Protected | Masked |
|----------|-------|------|-----------|--------|
| `APPLE_ID` | `corywatch@icloud.com` | Variable | ✅ | ❌ |
| `APPLE_ID_PASSWORD` | `tqzc-dyao-ybdw-qtlh` | Variable | ✅ | ✅ |
| `FASTLANE_USER` | `corywatch@icloud.com` | Variable | ✅ | ❌ |
| `FASTLANE_PASSWORD` | `tqzc-dyao-ybdw-qtlh` | Variable | ✅ | ✅ |
| `FASTLANE_SESSION` | `M1Jsai/ZKg4deGZ3PytxENXVUIoYFRrSXVsbEO3vGn9TznEV38ud9PW3nJA+DI82
nRLmLrj62QQ4vUk3Z3vuQw==` | Variable | ✅ | ✅ |
| `MATCH_PASSWORD` | `HyanlGM0C/o2O4hZUl+tUBKTa+xpgw3nF5w1fbyBhYQ=` | Variable | ✅ | ✅ |
| `TEAM_ID` | `G7Z5DDPMSL` | Variable | ✅ | ❌ |
| `BUNDLE_ID` | `com.crownandbarrel.app` | Variable | ❌ | ❌ |

## Optional Variables

| Variable | Value | Type | Protected | Masked |
|----------|-------|------|-----------|--------|
| `IOS_SIMULATOR_NAME` | `iPhone 16` | Variable | ❌ | ❌ |
| `BUILD_CONFIGURATION` | `Release` | Variable | ❌ | ❌ |

## File Variables (for certificates)

| Variable | File Path | Type | Protected | Masked |
|----------|-----------|------|-----------|--------|
| `CERTIFICATE_P12` | `path/to/certificate.p12` | File | ✅ | ❌ |
| `CERTIFICATE_PASSWORD` | `certificate-password` | Variable | ✅ | ✅ |

