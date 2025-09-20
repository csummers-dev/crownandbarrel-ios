# Troubleshooting Guide

This guide covers common issues, build errors, and debugging solutions for Crown & Barrel development.

## Table of Contents

- [Project Generation Issues](#project-generation-issues)
- [Build Errors](#build-errors)
- [Simulator Issues](#simulator-issues)
- [App Resources Issues](#app-resources-issues)
- [Testing Issues](#testing-issues)
- [Performance Issues](#performance-issues)
- [Getting Help](#getting-help)

## Project Generation Issues

### XcodeGen Not Found
**Error**: `command not found: xcodegen`

**Solution**:
```bash
# Install XcodeGen via Homebrew
brew install xcodegen

# Verify installation
xcodegen --version
```

### Project Generation Fails
**Error**: Project generation fails or creates incomplete project

**Solutions**:
```bash
# Ensure all required directories exist
mkdir -p Sources Tests/Unit Tests/UITests AppResources

# Clean and regenerate
rm -rf CrownAndBarrel.xcodeproj
xcodegen generate

# Verify project was created
ls -la CrownAndBarrel.xcodeproj
```

### Missing Source Files
**Error**: Source files not found during build

**Solution**:
```bash
# Check if Sources directory exists and has content
ls -la Sources/

# Regenerate project if needed
xcodegen generate
```

## Build Errors

### Xcode Version Issues
**Error**: Build fails with compatibility warnings

**Solution**:
- Ensure Xcode 16+ is installed
- Check that command line tools are updated:
  ```bash
  sudo xcode-select --install
  ```

### Swift Compilation Errors

#### Sendable Closure Warnings
**Error**: `Capture of 'X' with non-Sendable type 'Y' in a '@Sendable' closure`

**Root Cause**: Swift 6 concurrency safety warnings for Core Data operations.

**Solution**: Use weak references in Core Data closures:
```swift
// ❌ INCORRECT - Causes Sendable warnings
await stack.viewContext.perform { [self, stack] in
    // Core Data operations
}

// ✅ CORRECT - Prevents Sendable warnings
await stack.viewContext.perform { [weak self, weak stack] in
    guard let self = self, let stack = stack else { throw AppError.unknown }
    // Core Data operations
}
```

**Files Affected**: 
- `WatchRepositoryCoreData.swift`
- `BackupRepositoryFile.swift`

**Critical**: Never remove `[weak self]` or `[weak stack]` patterns in Core Data closures as this will reintroduce Sendable warnings.

#### Missing Return Statements in Closures
**Error**: `Missing return in closure expected to return 'Bool'`

**Solution**: Ensure all closures with return types have explicit return statements:
```swift
// ❌ INCORRECT - Missing return
try await stack.viewContext.perform { [weak self] in
    guard let self = self else { throw AppError.unknown }
    try self.existsWearEntrySync(watchId: watchId, date: self.calendar.startOfDay(for: date))
}

// ✅ CORRECT - Explicit return
try await stack.viewContext.perform { [weak self] in
    guard let self = self else { throw AppError.unknown }
    return try self.existsWearEntrySync(watchId: watchId, date: self.calendar.startOfDay(for: date))
}
```

#### AppError.unknown Missing
**Error**: `Type 'AppError' has no member 'unknown'`

**Solution**: Ensure `AppError.unknown` case exists in `AppError.swift`:
```swift
public enum AppError: LocalizedError, Equatable {
    // ... other cases ...
    case unknown
    
    public var errorDescription: String? {
        // ... other cases ...
        case .unknown:
            return "An unknown error occurred."
    }
}
```

#### Static Member Reference Errors
**Error**: `Static member 'X' cannot be used on instance of type 'Y'`

**Solution**: Use explicit type qualification:
```swift
// ❌ INCORRECT - Instance reference to static member
var isRequiredForiPhone: Bool {
    return iPhoneIcons.contains(self)
}

// ✅ CORRECT - Explicit type qualification
var isRequiredForiPhone: Bool {
    return AppIconSize.iPhoneIcons.contains(self)
}
```

#### UIScreen Notification Issues
**Error**: `Type 'UIScreen' has no member 'traitCollectionDidChangeNotification'`

**Solution**: Use proper notification names or remove invalid references:
```swift
// ❌ INCORRECT - Invalid notification
NotificationCenter.default.addObserver(
    forName: UIScreen.traitCollectionDidChangeNotification,
    object: nil,
    queue: .main
) { [weak self] _ in
    // handler
}

// ✅ CORRECT - Remove or use valid notification
private func setupSystemAppearanceObserver() {
    // Note: System appearance changes are handled automatically by iOS
    // This method is reserved for future manual theme switching
}
```

#### Variable Mutation Warnings
**Error**: `Variable 'X' was never mutated; consider changing to 'let' constant`

**Solution**: Change `var` to `let` for immutable variables:
```swift
// ❌ INCORRECT - Variable never mutated
var invalidSizes: [String] = []

// ✅ CORRECT - Use let for immutable
let invalidSizes: [String] = []
```

### Clean Build Issues
**Error**: Build errors persist after code changes

**Solutions**:
- Clean build folder in Xcode (⌘+Shift+K)
- Clean derived data:
  ```bash
  rm -rf ~/Library/Developer/Xcode/DerivedData
  ```
- Reset package cache:
  ```bash
  xcodebuild -resolvePackageDependencies
  ```

### Swift Package Manager Issues
**Error**: Package resolution fails

**Solutions**:
```bash
# Clean package cache
rm -rf ~/Library/Caches/org.swift.swiftpm

# Reset package resolution
rm -rf .build
xcodebuild -resolvePackageDependencies
```

## Simulator Issues

### Simulator Not Available
**Error**: Target simulator not found

**Solutions**:
```bash
# List available simulators
xcrun simctl list devices | grep -E "iPhone 1|Booted"

# Boot specific simulator
xcrun simctl boot "iPhone 16"

# Reset simulator if corrupted
xcrun simctl erase "iPhone 16"
```

### App Installation Fails
**Error**: App fails to install on simulator

**Solutions**:
- Reset simulator completely
- Check available storage space
- Restart Xcode and simulator

### Simulator Performance Issues
**Symptoms**: Slow performance, laggy animations

**Solutions**:
- Close other apps on your Mac
- Increase simulator memory allocation
- Use a physical device for performance testing

## App Resources Issues

### Launch Screen Not Found
**Error**: `LaunchScreen.storyboard` not found

**Solution**:
```bash
# Verify file exists
ls -la AppResources/LaunchScreen.storyboard

# Check Info.plist configuration
grep -A 1 "UILaunchStoryboardName" AppResources/Info.plist
```

### Missing Assets
**Error**: Asset catalog issues

**Solution**:
- Verify `AppResources/Assets.xcassets` exists
- Check that all required app icons are present
- Ensure `Contents.json` files are valid

### App Icon Asset Catalog Issues
**Error**: `The app icon set "AppIcon" has X unassigned children`

**Root Cause**: Extra files in the app icon directory that aren't referenced in `Contents.json`.

**Solution**:
```bash
# Check for unassigned files
ls -la AppResources/Assets.xcassets/AppIcon.appiconset/

# Remove system files and unused icons
rm AppResources/Assets.xcassets/AppIcon.appiconset/.DS_Store
rm AppResources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024-dark.png  # Marketing icons don't need dark mode
```

**Prevention**:
- Only include icons that are referenced in `Contents.json`
- Don't add dark mode variants for marketing icons (1024x1024)
- Use the icon generation script: `./scripts/generate-app-icons.sh`
- Avoid creating backup directories in the AppIcon.appiconset folder
- Clean build when asset catalog issues persist

**Files to Check**:
- `AppResources/Assets.xcassets/AppIcon.appiconset/Contents.json`
- All icon files in the AppIcon.appiconset directory

**Advanced Solution**:
If the issue persists after removing unassigned files, try a clean build:
```bash
xcodebuild clean -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel build
```

### Theme Files Not Loading
**Error**: Themes not applying correctly

**Solutions**:
- Verify `AppResources/Themes.json` exists and is valid JSON
- Check theme loading in `ThemeManager.swift`
- Test with sample data to isolate theme issues

## Testing Issues

### Tests Not Running
**Error**: Test target not found or tests fail to run

**Solutions**:
```bash
# Run tests from command line
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run specific test target
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelTests
```

### UI Test Failures
**Error**: UI tests fail inconsistently

**Solutions**:
- Ensure simulator is in a clean state
- Add appropriate wait conditions for UI elements
- Check for timing issues in test code
- Verify accessibility identifiers are set correctly

### Core Data Test Issues
**Error**: Core Data tests fail with persistence issues

**Solutions**:
- Use in-memory store for unit tests
- Ensure proper test data cleanup
- Check Core Data stack configuration in tests

## Performance Issues

### App Launch Time
**Symptoms**: Slow app startup

**Debugging Steps**:
- Profile with Instruments (Time Profiler)
- Check for heavy operations in `App` initialization
- Review Core Data stack setup
- Minimize work in main thread during launch

### Memory Usage
**Symptoms**: High memory consumption

**Debugging Steps**:
- Use Memory Graph Debugger in Xcode
- Check for retain cycles in view models
- Monitor image loading and caching
- Review Core Data fetch requests

### UI Responsiveness
**Symptoms**: Laggy scrolling, slow animations

**Debugging Steps**:
- Profile with Instruments (Core Animation)
- Check for expensive operations on main thread
- Review SwiftUI view complexity
- Optimize image loading and display

## Getting Help

### Before Asking for Help

1. **Check this guide** - Your issue might already be documented
2. **Search existing issues** - Look through [GitLab Issues](https://gitlab.com/csummersdev/crown-and-barrel/-/issues)
3. **Try basic solutions** - Clean builds, restart Xcode, reset simulator
4. **Gather information** - Device/simulator info, error logs, reproduction steps

### Creating an Issue

When creating a new issue, please include:

- **Environment**: macOS version, Xcode version, iOS simulator version
- **Reproduction steps**: Detailed steps to reproduce the issue
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Error messages**: Full error logs and stack traces
- **Screenshots**: If applicable

### Debug Information

When reporting issues, include this debug information:

```bash
# System information
sw_vers
xcodebuild -version
xcrun simctl list devices | grep -E "iPhone 1|Booted"

# Project information
git log --oneline -5
ls -la Sources/ Tests/
```

### Contact

- **GitLab Issues**: [Create an issue](https://gitlab.com/csummersdev/crown-and-barrel/-/issues/new)
- **Email**: [csummersdev@icloud.com](mailto:csummersdev@icloud.com)

## Haptic Feedback Issues

### **Haptic Feedback Not Working**

#### **Symptoms**
- No tactile feedback when interacting with UI elements
- Haptics work in some areas but not others
- Haptic feedback is inconsistent

#### **Root Cause**
- Device doesn't support haptic feedback
- Haptic feedback is disabled in system settings
- Haptic engine is not properly initialized

#### **Solution**
1. **Check Device Support**:
   ```swift
   // Verify haptic feedback is available
   if UIDevice.current.userInterfaceIdiom == .phone {
       // iPhone supports haptic feedback
   }
   ```

2. **Check System Settings**:
   - Go to Settings > Sounds & Haptics
   - Ensure "System Haptics" is enabled
   - Verify "Vibrate on Ring" and "Vibrate on Silent" are enabled

3. **Test Haptic Engine**:
   ```swift
   // Test basic haptic functionality
   Haptics.lightImpact()
   ```

#### **Prevention**
- Always test haptic feedback on actual devices
- Provide graceful degradation for unsupported devices
- Don't rely solely on haptic feedback for critical interactions

### **Haptic Feedback Too Intense or Weak**

#### **Symptoms**
- Haptic feedback feels too strong or too weak
- Inconsistent haptic intensity across interactions
- Haptic feedback is overwhelming or barely noticeable

#### **Root Cause**
- Using inappropriate haptic intensity for interaction type
- Device haptic settings are customized
- Haptic engine calibration issues

#### **Solution**
1. **Use Appropriate Intensity**:
   ```swift
   // Light impact for subtle interactions
   Haptics.lightImpact()
   
   // Medium impact for important actions
   Haptics.mediumImpact()
   
   // Heavy impact for critical operations
   Haptics.heavyImpact()
   ```

2. **Check Device Settings**:
   - Go to Settings > Accessibility > Touch > Haptic Touch
   - Adjust haptic feedback intensity
   - Test with different intensity levels

3. **Use Contextual Feedback**:
   ```swift
   // Use contextual methods for appropriate intensity
   Haptics.collectionInteraction()    // Light impact
   Haptics.formInteraction()          // Selection feedback
   Haptics.wearTracking(.markAsWorn)  // Success notification
   ```

#### **Prevention**
- Follow haptic intensity guidelines
- Test on multiple devices with different settings
- Use contextual haptic methods instead of raw intensity

### **Haptic Feedback Spam/Overwhelming**

#### **Symptoms**
- Multiple haptic feedbacks triggered rapidly
- Overwhelming tactile feedback during interactions
- Poor user experience due to excessive haptics

#### **Root Cause**
- Not using debouncing for rapid interactions
- Multiple haptic calls triggered simultaneously
- Inappropriate haptic timing

#### **Solution**
1. **Use Debounced Haptics**:
   ```swift
   // Debounce rapid interactions
   Haptics.debouncedHaptic {
       Haptics.collectionInteraction()
   }
   ```

2. **Avoid Multiple Haptics**:
   ```swift
   // ❌ INCORRECT - Multiple haptics
   Haptics.lightImpact()
   Haptics.selection()
   
   // ✅ CORRECT - Single appropriate haptic
   Haptics.formInteraction()
   ```

3. **Check Interaction Timing**:
   - Ensure haptics are triggered at appropriate moments
   - Avoid haptics during rapid scrolling or gestures
   - Use haptics for user-initiated actions only

#### **Prevention**
- Always use `Haptics.debouncedHaptic()` for rapid interactions
- Test with rapid user interactions
- Follow haptic usage guidelines

### **Haptic Feedback Accessibility Issues**

#### **Symptoms**
- Haptic feedback interferes with screen readers
- Inconsistent haptic feedback for accessibility users
- Haptic feedback not working with accessibility features

#### **Root Cause**
- Not providing enhanced feedback for accessibility users
- Haptic feedback conflicts with accessibility features
- Missing accessibility-specific haptic patterns

#### **Solution**
1. **Use Enhanced Accessibility Feedback**:
   ```swift
   // Enhanced feedback for accessibility users
   Haptics.accessibleInteraction(.elementSelected)
   Haptics.accessibleInteraction(.actionCompleted)
   ```

2. **Test with Accessibility Features**:
   - Enable VoiceOver and test haptic feedback
   - Test with Switch Control enabled
   - Verify haptic feedback doesn't interfere with accessibility

3. **Provide Alternative Feedback**:
   - Ensure visual and audio feedback complement haptics
   - Don't rely solely on haptic feedback
   - Provide clear visual confirmation of actions

#### **Prevention**
- Test haptic feedback with accessibility features enabled
- Use enhanced accessibility haptic methods
- Ensure haptic feedback enhances rather than replaces other feedback

### **Haptic Feedback Performance Issues**

#### **Symptoms**
- UI lag when haptic feedback is triggered
- App performance degradation with haptics enabled
- Slow response times during haptic interactions

#### **Root Cause**
- Haptic feedback called on background threads
- Excessive haptic engine initialization
- Blocking operations during haptic calls

#### **Solution**
1. **Ensure Main Thread Execution**:
   ```swift
   // Haptic feedback should be called on main thread
   DispatchQueue.main.async {
       Haptics.lightImpact()
   }
   ```

2. **Optimize Haptic Calls**:
   ```swift
   // Use debouncing to prevent excessive calls
   Haptics.debouncedHaptic {
       Haptics.collectionInteraction()
   }
   ```

3. **Profile Performance**:
   - Use Instruments to measure haptic performance impact
   - Monitor main thread usage during haptic interactions
   - Optimize haptic call frequency

#### **Prevention**
- Always call haptic feedback on main thread
- Use debouncing for rapid interactions
- Monitor performance impact of haptic feedback

---

*This troubleshooting guide is maintained by the Crown & Barrel development team. If you encounter an issue not covered here, please create a new issue with detailed information.*
