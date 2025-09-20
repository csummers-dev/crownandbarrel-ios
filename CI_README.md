# GitLab CI/CD Setup for Crown & Barrel

This document explains how to set up and configure the GitLab CI/CD pipeline for the Crown & Barrel iOS app.

## Overview

The CI/CD pipeline includes the following stages:
- **Setup**: Install dependencies and generate Xcode project
- **Lint**: Run SwiftLint for code quality checks
- **Build**: Compile the application
- **Test**: Run unit and UI tests
- **Deploy**: Archive and deploy to TestFlight/App Store

## Prerequisites

### GitLab Runner Setup

You'll need a GitLab Runner with the following capabilities:

1. **macOS Runner** with Xcode 16.0+
2. **Runner Tags**: `macos`, `ios`, `xcode`
3. **Docker Image**: `registry.gitlab.com/gitlab-org/incubator/mobile-devops/xcode:16.0`

### Required Software

The pipeline automatically installs:
- XcodeGen (for project generation)
- SwiftLint (for code quality)
- xcparse (for test result parsing)

## Configuration Files

### `.gitlab-ci.yml`
Main CI/CD configuration file with all pipeline stages and jobs.

### `.swiftlint.yml`
SwiftLint configuration with iOS-specific rules and customizations.

### `exportOptions.plist`
Export configuration for IPA generation (requires customization).

## Setup Instructions

### 1. Basic Setup

The pipeline is ready to run with minimal configuration. It will:
- Generate the Xcode project using XcodeGen
- Run SwiftLint code quality checks
- Build the application for iOS Simulator
- Run unit and UI tests
- Create archives for distribution

### 2. TestFlight Deployment Setup

To enable TestFlight deployment, you'll need to:

1. **Set up Apple Developer Account**:
   - Create App Store Connect API key
   - Generate provisioning profiles
   - Create code signing certificates

2. **Configure GitLab CI/CD Variables**:
   ```
   APPLE_ID: your-apple-id@example.com
   APPLE_ID_PASSWORD: your-app-specific-password
   FASTLANE_USER: your-apple-id@example.com
   FASTLANE_PASSWORD: your-app-specific-password
   FASTLANE_SESSION: your-session-token
   MATCH_PASSWORD: your-match-password
   TEAM_ID: your-team-id
   ```

3. **Install Fastlane** (optional but recommended):
   ```bash
   gem install fastlane
   ```

4. **Create Fastfile** in `fastlane/` directory:
   ```ruby
   platform :ios do
     desc "Push a new beta build to TestFlight"
     lane :beta do
       increment_build_number
       build_app(scheme: "CrownAndBarrel")
       upload_to_testflight
     end
   end
   ```

### 3. App Store Deployment Setup

Similar to TestFlight but with additional steps:

1. **Configure App Store Connect**:
   - Set up app metadata
   - Configure pricing and availability
   - Upload app screenshots

2. **Update Fastfile** for App Store:
   ```ruby
   platform :ios do
     desc "Deploy to App Store"
     lane :release do
       increment_build_number
       build_app(scheme: "CrownAndBarrel")
       upload_to_app_store(
         force: true,
         skip_metadata: false,
         skip_screenshots: false
       )
     end
   end
   ```

## Customization

### Runner Configuration

If you're using a different runner setup, update the `tags` and `image` in `.gitlab-ci.yml`:

```yaml
.ios_base:
  image: your-custom-xcode-image:16.0
  tags:
    - your-runner-tags
```

### Build Configuration

Modify build settings in the `variables` section:

```yaml
variables:
  XCODE_VERSION: "16.0"
  IOS_SIMULATOR_NAME: "iPhone 16"
  BUILD_CONFIGURATION: "Release"
```

### Test Configuration

Customize test settings:

```yaml
# Run specific test targets
- only-testing:"CrownAndBarrelTests/SomeSpecificTest"

# Run tests on specific device
- destination "platform=iOS Simulator,name=iPhone 15 Pro,OS=17.5"
```

## Troubleshooting

### Common Issues

1. **XcodeGen Not Found**:
   - The pipeline automatically installs XcodeGen via Homebrew
   - If issues persist, ensure the runner has Homebrew installed

2. **Simulator Issues**:
   - Check available simulators: `xcrun simctl list devices`
   - Verify simulator name matches configuration
   - Reset simulator if needed: `xcrun simctl erase "iPhone 16"`

3. **Build Failures**:
   - Check Xcode version compatibility
   - Verify all dependencies are resolved
   - Review build logs for specific errors

4. **Test Failures**:
   - Ensure tests can run on the specified simulator
   - Check for UI test stability issues
   - Review test result artifacts

### Debug Mode

To enable debug output, add to job scripts:

```yaml
script:
  - set -x  # Enable debug mode
  - echo "Debug information here"
```

### Manual Pipeline Triggers

You can manually trigger specific jobs:
- Go to GitLab → CI/CD → Pipelines
- Click "Run pipeline"
- Select specific jobs to run

## Security Considerations

### Secrets Management

Never commit sensitive information to the repository:
- Apple Developer credentials
- Code signing certificates
- API keys
- Provisioning profiles

Use GitLab CI/CD variables for all secrets:
- Mark variables as "Protected" for production
- Use "Masked" for sensitive values
- Consider using "File" type for certificates

### Code Signing

For production deployments:
- Use proper code signing certificates
- Store certificates in GitLab CI/CD variables
- Implement proper certificate management (e.g., Fastlane Match)

## Monitoring and Maintenance

### Pipeline Monitoring

- Monitor pipeline success rates
- Set up notifications for failures
- Review build times and optimize if needed

### Regular Updates

- Keep Xcode version updated
- Update SwiftLint rules as needed
- Review and update dependencies
- Test pipeline changes in feature branches

## Support

For issues with the CI/CD pipeline:
1. Check GitLab CI/CD documentation
2. Review pipeline logs for specific errors
3. Test changes locally before committing
4. Create issues in the project repository

## Additional Resources

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [iOS CI/CD Best Practices](https://docs.gitlab.com/ee/ci/examples/ios/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
