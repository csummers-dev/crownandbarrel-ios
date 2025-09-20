# GitHub Actions Workflows Documentation
## Crown & Barrel iOS App - CI/CD Pipeline

### 🎯 **Overview**

This document describes the GitHub Actions workflows that power the Crown & Barrel iOS app's continuous integration and deployment pipeline.

### 📋 **Workflow Overview**

| Workflow | Trigger | Purpose | Duration |
|----------|---------|---------|----------|
| **CI Pipeline** | Push/PR | Build, test, and validate | ~15-20 min |
| **Release Pipeline** | Tags/Manual | Deploy to TestFlight/App Store | ~10-15 min |
| **Validation Pipeline** | Push/PR/Daily | Validate configs and dependencies | ~5-10 min |
| **Security Pipeline** | Push/PR/Weekly | Security scanning and analysis | ~10-15 min |
| **Security Audit** | Weekly/Manual | Comprehensive security auditing | ~15-20 min |
| **Performance Monitor** | Daily/Manual | Performance monitoring and optimization | ~10-15 min |
| **Dependency Update** | Weekly/Manual | Update dependencies | ~5-10 min |

### 🔄 **Main CI/CD Pipeline** (`ci.yml`)

#### **Stages:**
1. **Setup** - Install dependencies and generate Xcode project
2. **Lint** - Run SwiftLint for code quality
3. **Build** - Compile for Debug and Release configurations
4. **Test** - Run unit tests and UI tests
5. **Archive** - Create distribution archives
6. **Cleanup** - Clean up simulator and temporary files

#### **Key Features:**
- ✅ **Matrix Builds**: Builds for both Debug and Release configurations
- ✅ **Parallel Testing**: Unit tests and UI tests run in parallel
- ✅ **Artifact Caching**: Caches Swift Package Manager and DerivedData
- ✅ **Robust Installation**: Multi-strategy dependency installation with fallbacks
- ✅ **Conditional Testing**: Graceful handling of simulator unavailability
- ✅ **Architecture Detection**: Automatic ARM64/x86_64 handling
- ✅ **Artifact Upload**: Uploads build artifacts and test results

#### **Triggers:**
- Push to `main`, `develop`, or `feature/*` branches
- Pull requests to `main` or `develop` branches

### 🚀 **Release Pipeline** (`release.yml`)

#### **Deployment Options:**
1. **TestFlight Deployment**
   - Triggered by tags or manual workflow dispatch
   - Creates archive and prepares for TestFlight upload
   - Requires Apple Developer account setup

2. **App Store Deployment**
   - Manual trigger only
   - Creates archive and prepares for App Store submission
   - Requires App Store Connect setup

3. **GitHub Release Creation**
   - Automatically creates GitHub releases for tags
   - Includes release notes and artifacts

#### **Required Secrets:**
- `APPLE_ID` - Apple Developer account email
- `APPLE_ID_PASSWORD` - App-specific password
- `TEAM_ID` - Apple Developer team ID
- `FASTLANE_*` - Fastlane configuration secrets

### 🔍 **Validation Pipeline** (`validate.yml`)

#### **Validation Checks:**
1. **YAML Validation** - Validates all YAML configuration files
2. **Swift Syntax** - Basic Swift syntax validation
3. **Dependencies** - Swift Package Manager dependency validation
4. **Security** - Trivy vulnerability scanning
5. **Code Quality** - SwiftLint code quality checks
6. **Documentation** - Markdown file validation
7. **Configuration** - Project configuration validation
8. **Performance** - Build performance monitoring

#### **Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Daily scheduled runs at 2 AM UTC

### 🔒 **Security Pipeline** (`security.yml`)

#### **Security Scans:**
1. **CodeQL Analysis** - GitHub's code analysis engine
2. **Dependency Scanning** - Trivy vulnerability scanner
3. **Secret Scanning** - TruffleHog secret detection
4. **License Compliance** - License compatibility checking
5. **Security Policy** - Security documentation validation

#### **Features:**
- ✅ **SARIF Upload**: Uploads results to GitHub Security tab
- ✅ **Weekly Schedule**: Runs every Sunday at 3 AM UTC
- ✅ **Comprehensive Coverage**: Multiple security scanning tools
- ✅ **Automated Reporting**: Results automatically uploaded to GitHub

### 🔍 **Security Audit Pipeline** (`security-audit.yml`)

#### **Audit Types:**
1. **Comprehensive Security Audit** - Full security assessment
2. **Static Analysis** - Semgrep integration for code analysis
3. **Custom Security Checks** - Hardcoded secrets, insecure connections
4. **License Compliance** - Dependency license validation
5. **Security Policy Validation** - Policy and documentation checks
6. **GitHub Actions Security** - Workflow security auditing

#### **Features:**
- ✅ **Weekly Schedule**: Runs every Wednesday at 2 AM UTC
- ✅ **Manual Trigger**: Can be triggered manually with audit type selection
- ✅ **Comprehensive Coverage**: Multiple security auditing tools
- ✅ **Automated Reporting**: Results automatically uploaded to GitHub

### 📊 **Performance Monitor Pipeline** (`performance-monitor.yml`)

#### **Monitoring Types:**
1. **Build Performance** - Build time monitoring and optimization
2. **Test Performance** - Test execution time tracking
3. **Resource Monitoring** - System resource usage tracking
4. **Performance Analysis** - Automated performance assessment
5. **Optimization Recommendations** - Performance improvement suggestions

#### **Features:**
- ✅ **Daily Schedule**: Runs every day at 3 AM UTC
- ✅ **Manual Trigger**: Can be triggered manually with monitoring type selection
- ✅ **Comprehensive Metrics**: Build, test, and resource performance tracking
- ✅ **Performance Recommendations**: Automated optimization suggestions

### 📦 **Dependency Update Pipeline** (`dependency-update.yml`)

#### **Update Types:**
1. **Swift Package Manager** - Updates SPM dependencies
2. **Homebrew** - Updates Homebrew packages
3. **Fastlane** - Updates Fastlane gem
4. **GitHub Actions** - Checks for outdated actions
5. **Security Patches** - Checks for security updates

#### **Features:**
- ✅ **Weekly Schedule**: Runs every Monday at 4 AM UTC
- ✅ **Manual Trigger**: Can be triggered manually
- ✅ **Update Summaries**: Provides comprehensive update reports
- ✅ **PR Creation**: Creates pull requests for dependency updates

### 🔧 **Dependabot Configuration** (`dependabot.yml`)

#### **Supported Ecosystems:**
- **Swift Package Manager** - iOS app dependencies
- **GitHub Actions** - Workflow actions
- **npm** - Node.js tools (if used)
- **Docker** - Container images (if used)
- **Bundler** - Ruby gems (Fastlane)

#### **Features:**
- ✅ **Weekly Updates**: Automatic weekly dependency updates
- ✅ **Grouped PRs**: Groups related dependency updates
- ✅ **Auto-Assignment**: Automatically assigns PRs to maintainers
- ✅ **Smart Ignoring**: Ignores major version updates for stability

### 📊 **Workflow Performance**

#### **Typical Run Times:**
- **CI Pipeline**: 15-20 minutes
- **Release Pipeline**: 10-15 minutes
- **Validation Pipeline**: 5-10 minutes
- **Security Pipeline**: 10-15 minutes
- **Dependency Update**: 5-10 minutes

#### **Resource Usage:**
- **macOS Runners**: Used for iOS builds and testing
- **Ubuntu Runners**: Used for validation and security scanning
- **Parallel Execution**: Multiple jobs run in parallel for efficiency

### 🎯 **Quality Gates**

#### **Required for Success:**
- ✅ All tests must pass
- ✅ SwiftLint must pass (warnings allowed)
- ✅ Security scans must pass
- ✅ Build must complete successfully
- ✅ Archive creation must succeed

#### **Failure Handling:**
- **Test Failures**: Block merge until fixed
- **Lint Warnings**: Allow merge but report warnings
- **Security Issues**: Block merge for critical vulnerabilities
- **Build Failures**: Block merge until resolved

### 🔐 **Security Considerations**

#### **Secrets Management:**
- All sensitive data stored in GitHub Secrets
- Secrets are masked in logs and outputs
- Environment-specific secret scoping
- Regular secret rotation recommended

#### **Access Control:**
- Branch protection rules enforce required checks
- Environment protection for production deployments
- Manual approval required for App Store releases
- Audit trail for all deployments

### 📈 **Monitoring and Analytics**

#### **GitHub Insights:**
- Workflow run history and success rates
- Performance metrics and duration trends
- Failure analysis and debugging information
- Resource usage and cost tracking

#### **Custom Metrics:**
- Build performance tracking
- Test coverage monitoring
- Security scan results
- Dependency update frequency

### 🔧 **Robust Installation Strategies**

#### **Multi-Strategy Dependency Installation:**

The pipeline implements a robust three-strategy approach for installing dependencies:

1. **Direct Download (Primary Strategy)**
   - Downloads pre-compiled binaries from GitHub releases
   - Most reliable and fastest installation method
   - Avoids Homebrew architecture conflicts entirely

2. **Homebrew with ARM64 Forcing (Fallback Strategy)**
   - Uses `arch -arm64` to force correct architecture
   - Tries multiple Homebrew installation paths
   - Handles GitHub Actions runner environment differences

3. **Swift Package Manager (Last Resort Strategy)**
   - Compiles from source if other methods fail
   - Ensures installation even in edge cases
   - Provides maximum compatibility

#### **Implementation Example:**
```bash
# Strategy 1: Direct download (most reliable)
curl -fsSL https://github.com/yonaskolb/XcodeGen/releases/latest/download/xcodegen.zip -o xcodegen.zip
unzip -o xcodegen.zip
sudo mv xcodegen /usr/local/bin/

# Strategy 2: Homebrew with ARM64 forcing
for brew_path in "/opt/homebrew/bin/brew" "/usr/local/bin/brew" "brew"; do
  if arch -arm64 $brew_path install xcodegen 2>/dev/null; then
    break
  fi
done

# Strategy 3: Swift Package Manager
swift build -c release --package-path /tmp --package-url https://github.com/yonaskolb/XcodeGen.git --product xcodegen
```

### 🚨 **Troubleshooting**

#### **Common Issues:**
1. **Homebrew Architecture Conflicts**: Use multi-strategy installation approach
2. **Simulator Boot Failures**: Check available simulators and iOS versions
3. **Build Timeouts**: Optimize build configuration and caching
4. **Test Failures**: Check test environment and device compatibility
5. **Secret Issues**: Verify secret configuration and permissions

#### **Debug Steps:**
1. Check workflow run logs for specific errors
2. Verify environment and runner availability
3. Test locally with same configuration
4. Check GitHub Actions service status

### 📚 **Additional Resources**

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Swift Package Manager](https://swift.org/package-manager/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [CodeQL Documentation](https://codeql.github.com/docs/)

---

**This CI/CD pipeline ensures high-quality, secure, and reliable builds for the Crown & Barrel iOS app.**
