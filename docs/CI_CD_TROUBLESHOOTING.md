# CI/CD Pipeline Troubleshooting Guide

This guide covers common issues and solutions for the CrownAndBarrel iOS CI/CD pipeline running on GitHub Actions.

## Overview

The CI/CD pipeline has been optimized for GitHub Actions runners with multiple fallback strategies for reliability and compatibility across different runner environments.

## Common Issues and Solutions

### 1. Homebrew Architecture Conflicts

**Error:**
```
Error: Cannot install under Rosetta 2 in ARM default prefix (/opt/homebrew)!
To rerun under ARM use:
    arch -arm64 brew install ...
```

**Root Cause:**
GitHub Actions runners may have mixed ARM64/x86_64 environments, causing Homebrew to install packages under the wrong architecture.

**Solution:**
The pipeline implements a multi-strategy approach:

1. **Direct Download** (Primary): Downloads binaries directly from GitHub releases
2. **Homebrew with ARM64 Forcing** (Fallback): Uses `arch -arm64` to force correct architecture
3. **Swift Package Manager** (Last Resort): Compiles from source if needed

**Implementation:**
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
```

### 2. iOS Simulator Availability Issues

**Error:**
```
xcodebuild: error: Unable to find a destination matching the provided destination specifier:
{ generic:1, platform:iOS Simulator }
```

**Root Cause:**
GitHub Actions runners may not have iOS Simulators available or configured.

**Solution:**
The pipeline uses a hybrid approach:

1. **Builds**: Use iOS device target (`generic/platform=iOS`) - always available
2. **Tests**: Conditional execution based on simulator availability

**Implementation:**
```bash
# Check for available simulators
AVAILABLE_SIMULATORS=$(xcrun simctl list devices available | grep iPhone | wc -l)

# Run tests only if simulators are available
if [[ $AVAILABLE_SIMULATORS -gt 0 ]]; then
  # Run tests using available simulator
else
  # Skip tests with clear messaging
fi
```

### 3. iOS Simulator Runtime Version Conflicts

**Error:**
```
error: No simulator runtime version from [<DVTBuildVersion 22E238>, ...] 
available to use with iphonesimulator SDK version <DVTBuildVersion 22A3362>
```

**Root Cause:**
Mismatch between available iOS Simulator runtime versions and the SDK version being used.

**Solution:**
- Use iOS device builds instead of simulator builds for main compilation
- Use dynamic simulator detection for tests
- Implement fallback strategies for different iOS versions

### 4. Build Configuration Issues

**Common Problems:**
- Bitcode compatibility issues
- Code signing conflicts
- Architecture mismatches

**Solution:**
Optimized build settings:
```bash
xcodebuild build \
  -destination "generic/platform=iOS" \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=YES \
  VALID_ARCHS="arm64" \
  ARCHS="arm64" \
  ENABLE_BITCODE=NO
```

## Pipeline Architecture

### Build Strategy

1. **Setup Phase**: Environment preparation and dependency installation
2. **Lint Phase**: Code quality checks with SwiftLint
3. **Build Phase**: Compilation for iOS device target (always reliable)
4. **Test Phase**: Conditional execution based on simulator availability
5. **Deploy Phase**: Release artifact creation (main branch only)

### Reliability Features

- **Multi-Strategy Installation**: Multiple fallback methods for dependencies
- **Conditional Testing**: Graceful handling of simulator unavailability
- **Architecture Detection**: Automatic ARM64/x86_64 handling
- **Error Recovery**: Comprehensive error handling and fallback strategies
- **Clear Logging**: Detailed status messages for debugging

## Environment Variables

Key environment variables used in the pipeline:

```yaml
env:
  XCODE_VERSION: "16.0"
  PROJECT_NAME: "CrownAndBarrel"
  SCHEME_NAME: "CrownAndBarrel"
  BUNDLE_ID: "com.crownandbarrel.app"
```

## Best Practices

### For Developers

1. **Local Development**: Use the same Xcode version (16.0) as CI
2. **Testing**: Run tests locally before pushing to ensure compatibility
3. **Dependencies**: Keep dependencies up to date to avoid version conflicts

### For CI/CD Maintenance

1. **Monitor Builds**: Watch for architecture-related failures
2. **Update Dependencies**: Regularly update XcodeGen and SwiftLint versions
3. **Test Changes**: Validate CI changes in feature branches before merging

## Debugging Tips

### Check Runner Environment
```bash
# Check architecture
uname -m

# Check available tools
which brew
which swift
which curl

# Check Xcode version
xcodebuild -version

# Check available simulators
xcrun simctl list devices
```

### Verify Installation Success
```bash
# Check if tools are properly installed
xcodegen --version
swiftlint version

# Verify installation paths
which xcodegen
which swiftlint
```

## Future Improvements

### Planned Enhancements

1. **Caching**: Implement dependency caching for faster builds
2. **Parallel Jobs**: Optimize job dependencies for parallel execution
3. **Custom Runners**: Consider dedicated runners for more control
4. **Advanced Testing**: Implement more sophisticated test strategies

### Monitoring

- **Build Metrics**: Track build times and success rates
- **Dependency Updates**: Monitor for security updates
- **Runner Performance**: Optimize for GitHub Actions runner efficiency

## Support

For CI/CD issues:

1. Check this troubleshooting guide
2. Review pipeline logs for specific error messages
3. Test fixes in feature branches before merging
4. Consider environment-specific solutions for persistent issues

## Related Documentation

- [Pipeline Maintenance Guide](PIPELINE_MAINTENANCE_GUIDE.md) - **CRITICAL**: Systematic procedures to prevent missed workflow updates
- [GitHub Actions Workflows](.github/ACTIONS_README.md)
- [Migration Summary](MIGRATION_COMPLETE.md)
- [Architecture Guide](ARCHITECTURE.md)
- [Testing Guide](TESTING_GUIDE.md)
