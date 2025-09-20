# Testing Guide

This guide provides comprehensive information about testing strategies, guidelines, and best practices for Crown & Barrel.

## Table of Contents

- [Testing Philosophy](#testing-philosophy)
- [Test Categories](#test-categories)
- [Running Tests](#running-tests)
- [Unit Testing](#unit-testing)
- [UI Testing](#ui-testing)
- [Integration Testing](#integration-testing)
- [Test Data Management](#test-data-management)
- [Mock Objects](#mock-objects)
- [Testing Best Practices](#testing-best-practices)
- [Continuous Integration](#continuous-integration)
- [Code Coverage](#code-coverage)
- [Performance Testing](#performance-testing)
- [Accessibility Testing](#accessibility-testing)

## Testing Philosophy

### Core Principles
- **Test-Driven Development**: Write tests before or alongside implementation
- **Comprehensive Coverage**: Aim for high test coverage on critical paths
- **Fast Feedback**: Tests should run quickly and provide immediate feedback
- **Reliable Tests**: Tests should be deterministic and not flaky
- **Clear Intent**: Tests should clearly express what they're testing

### Testing Pyramid
```
        /\
       /  \
      / UI \     (Few, high-level, slow)
     /______\
    /        \
   /Integration\  (Some, medium-level, medium speed)
  /____________\
 /              \
/   Unit Tests   \  (Many, low-level, fast)
/________________\
```

## Test Categories

### Unit Tests
- **Purpose**: Test individual components in isolation
- **Scope**: Business logic, utilities, data transformations
- **Speed**: Fast (< 1 second per test)
- **Location**: `Tests/Unit/`

### UI Tests
- **Purpose**: Test user interactions and workflows
- **Scope**: Complete user flows, navigation, form validation
- **Speed**: Medium (1-10 seconds per test)
- **Location**: `Tests/UITests/`

### Integration Tests
- **Purpose**: Test component interactions and data flow
- **Scope**: Repository implementations, Core Data operations
- **Speed**: Medium (1-5 seconds per test)
- **Location**: Mixed between Unit and UI tests

## Running Tests

### Xcode
```bash
# Run all tests
⌘+U

# Run specific test target
⌘+Shift+U (select target)
```

### Command Line
```bash
# Run all tests
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run unit tests only
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelTests

# Run UI tests only
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelUITests

# Run specific test class
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelTests/WatchRepositoryTests

# Run specific test method
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelTests/WatchRepositoryTests/test_whenAddingWatch_thenWatchIsPersisted
```

### Test Discovery
```bash
# List all test methods
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -dry-run
```

## Unit Testing

### Test Structure
```swift
import XCTest
@testable import CrownAndBarrel

class WatchRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    var repository: WatchRepository!
    var coreDataStack: CoreDataStack!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack(inMemory: true)
        repository = WatchRepositoryCoreData(coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        repository = nil
        coreDataStack = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func test_whenAddingWatch_thenWatchIsPersisted() {
        // Given
        let watch = Watch(manufacturer: "Rolex", model: "Submariner")
        
        // When
        let expectation = XCTestExpectation(description: "Watch is added")
        repository.addWatch(watch) { result in
            // Then
            XCTAssertTrue(result.isSuccess)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
```

### Test Naming Convention
- **Format**: `test_whenCondition_thenExpectedResult()`
- **Examples**:
  - `test_whenUserTapsAddWatch_thenWatchFormIsPresented()`
  - `test_whenInvalidDataIsProvided_thenValidationErrorIsReturned()`
  - `test_whenThemeIsChanged_thenUIUpdatesCorrectly()`

### What to Test
- **Business Logic**: ViewModels, data transformations, calculations
- **Data Validation**: Input validation, data integrity checks
- **Error Handling**: Error conditions and recovery
- **Utilities**: Helper functions, date calculations, formatting
- **Repository Operations**: CRUD operations, data persistence

### Test Categories
- **Happy Path**: Normal operation scenarios
- **Edge Cases**: Boundary conditions, empty inputs
- **Error Conditions**: Invalid inputs, network failures
- **Performance**: Critical path performance

## UI Testing

### Test Structure
```swift
import XCTest

class AddWatchFlowUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func test_whenUserTapsAddWatch_thenWatchFormIsPresented() {
        // Given
        let addButton = app.buttons["Add Watch"]
        
        // When
        addButton.tap()
        
        // Then
        let watchForm = app.navigationBars["Add Watch"]
        XCTAssertTrue(watchForm.exists)
    }
}
```

### UI Element Identification
- **Accessibility Identifiers**: Primary method for element identification
- **Labels**: Use for buttons, labels, and other UI elements
- **Predicates**: For complex element queries

```swift
// Good - Using accessibility identifiers
let addButton = app.buttons["addWatchButton"]

// Good - Using labels
let addButton = app.buttons["Add Watch"]

// Avoid - Using indices or complex predicates
let addButton = app.buttons.element(boundBy: 0)
```

### UI Test Best Practices
- **Wait for Elements**: Use `waitForExistence` for dynamic content
- **Reset State**: Ensure clean state between tests
- **Stable Selectors**: Use accessibility identifiers over visual selectors
- **Test User Flows**: Focus on complete user journeys

### Common UI Test Patterns
```swift
// Wait for element to appear
let element = app.buttons["submitButton"]
XCTAssertTrue(element.waitForExistence(timeout: 5.0))

// Handle alerts
if app.alerts["Permission Alert"].exists {
    app.alerts["Permission Alert"].buttons["Allow"].tap()
}

// Scroll to element
let element = app.buttons["bottomButton"]
element.scrollToElement()

// Take screenshot
let screenshot = XCUIScreen.main.screenshot()
// Save screenshot for debugging
```

## Integration Testing

### Core Data Testing
```swift
class CoreDataIntegrationTests: XCTestCase {
    
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack(inMemory: true)
    }
    
    func test_whenSavingWatch_thenDataIsPersisted() {
        // Given
        let context = coreDataStack.viewContext
        let watch = WatchEntity(context: context)
        watch.manufacturer = "Rolex"
        watch.model = "Submariner"
        
        // When
        try? context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<WatchEntity> = WatchEntity.fetchRequest()
        let results = try? context.fetch(fetchRequest)
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.manufacturer, "Rolex")
    }
}
```

### Repository Testing
```swift
class WatchRepositoryIntegrationTests: XCTestCase {
    
    var repository: WatchRepository!
    var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack(inMemory: true)
        repository = WatchRepositoryCoreData(coreDataStack: coreDataStack)
    }
    
    func test_whenAddingMultipleWatches_thenAllAreRetrieved() {
        // Given
        let watch1 = Watch(manufacturer: "Rolex", model: "Submariner")
        let watch2 = Watch(manufacturer: "Omega", model: "Speedmaster")
        
        // When
        let expectation = XCTestExpectation(description: "Watches are added")
        repository.addWatch(watch1) { _ in
            self.repository.addWatch(watch2) { _ in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        let allWatches = repository.getAllWatches()
        XCTAssertEqual(allWatches.count, 2)
    }
}
```

## Test Data Management

### Test Fixtures
```swift
struct TestFixtures {
    
    static let sampleWatch = Watch(
        manufacturer: "Rolex",
        model: "Submariner",
        referenceNumber: "124060",
        serialNumber: "ABC123",
        purchaseDate: Date(),
        purchasePrice: 8100.00
    )
    
    static let sampleWearEntry = WearEntry(
        watchId: UUID(),
        date: Date(),
        notes: "Test wear entry"
    )
    
    static func createWatch(manufacturer: String = "Rolex", model: String = "Submariner") -> Watch {
        return Watch(
            manufacturer: manufacturer,
            model: model,
            referenceNumber: "TEST123",
            serialNumber: "TEST456"
        )
    }
}
```

### Test Data Cleanup
```swift
class BaseTestCase: XCTestCase {
    
    override func tearDown() {
        // Clean up test data
        cleanupTestData()
        super.tearDown()
    }
    
    private func cleanupTestData() {
        // Remove test files
        // Clear Core Data test store
        // Reset UserDefaults
        // Clean up any other test artifacts
    }
}
```

### Sample Data
```swift
class SampleDataTests: XCTestCase {
    
    func test_sampleDataIsValid() {
        // Given
        let sampleWatches = SampleData.watches
        
        // Then
        XCTAssertFalse(sampleWatches.isEmpty)
        XCTAssertTrue(sampleWatches.allSatisfy { !$0.manufacturer.isEmpty })
        XCTAssertTrue(sampleWatches.allSatisfy { !$0.model.isEmpty })
    }
}
```

## Mock Objects

### Protocol-Based Mocking
```swift
class MockWatchRepository: WatchRepository {
    
    var watches: [Watch] = []
    var shouldFail = false
    var error: Error?
    
    func getAllWatches() -> [Watch] {
        return watches
    }
    
    func addWatch(_ watch: Watch, completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldFail {
            completion(.failure(error ?? MockError.unknown))
        } else {
            watches.append(watch)
            completion(.success(()))
        }
    }
}

enum MockError: Error {
    case unknown
    case networkFailure
    case validationError
}
```

### Mock Usage in Tests
```swift
class WatchFormViewModelTests: XCTestCase {
    
    var viewModel: WatchFormViewModel!
    var mockRepository: MockWatchRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockWatchRepository()
        viewModel = WatchFormViewModel(repository: mockRepository)
    }
    
    func test_whenSavingWatch_thenRepositoryIsCalled() {
        // Given
        viewModel.manufacturer = "Rolex"
        viewModel.model = "Submariner"
        
        // When
        viewModel.saveWatch()
        
        // Then
        XCTAssertEqual(mockRepository.watches.count, 1)
        XCTAssertEqual(mockRepository.watches.first?.manufacturer, "Rolex")
    }
}
```

## Testing Best Practices

### Test Organization
- **One Test Class Per Class**: Mirror your source code structure
- **Descriptive Test Names**: Clear intent and expected behavior
- **Arrange-Act-Assert**: Structure tests with clear sections
- **Single Responsibility**: Each test should verify one thing

### Test Independence
- **No Dependencies**: Tests should not depend on other tests
- **Clean State**: Each test starts with a clean slate
- **Isolated Data**: Use test-specific data and mocks
- **Parallel Execution**: Tests should be able to run in parallel

### Test Maintenance
- **Regular Updates**: Keep tests in sync with code changes
- **Remove Obsolete Tests**: Delete tests for removed functionality
- **Refactor Tests**: Improve test code quality over time
- **Document Complex Tests**: Add comments for complex test logic

### Performance Considerations
- **Fast Execution**: Unit tests should run in milliseconds
- **Efficient Setup**: Minimize setup and teardown overhead
- **Mock Heavy Operations**: Use mocks for slow operations
- **Batch Operations**: Group related tests when possible

## Continuous Integration

### GitHub Actions Configuration
```yaml
test:
  stage: test
  script:
    - xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test
  artifacts:
    reports:
      junit: test-results.xml
  coverage: '/Code coverage: \d+\.\d+%/'
```

### Test Reporting
- **JUnit XML**: For test results and failures
- **Code Coverage**: Track test coverage metrics
- **Test Duration**: Monitor test execution time
- **Flaky Test Detection**: Identify unreliable tests

## Code Coverage

### Coverage Goals
- **Minimum**: 80% overall coverage
- **Critical Paths**: 95% coverage for business logic
- **UI Code**: 70% coverage for SwiftUI views
- **Utilities**: 90% coverage for helper functions

### Coverage Analysis
```bash
# Generate coverage report
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -enableCodeCoverage YES

# View coverage in Xcode
# Product → Show Code Coverage
```

### Coverage Exclusions
- **Generated Code**: Exclude auto-generated files
- **UI Boilerplate**: Exclude simple SwiftUI view code
- **Test Files**: Exclude test code itself
- **Third-Party Code**: Exclude external dependencies

## Performance Testing

### Performance Tests
```swift
class PerformanceTests: XCTestCase {
    
    func test_watchCollectionLoadPerformance() {
        // Given
        let repository = WatchRepositoryCoreData()
        let expectation = XCTestExpectation(description: "Performance test")
        
        // When
        measure {
            repository.getAllWatches { _ in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
```

### Performance Benchmarks
- **App Launch Time**: < 2 seconds
- **Collection Load Time**: < 500ms
- **Image Load Time**: < 200ms
- **Theme Switch Time**: < 100ms

### Memory Testing
- **Memory Leaks**: Use Xcode's Memory Graph Debugger
- **Memory Usage**: Monitor peak memory consumption
- **Retain Cycles**: Check for circular references
- **Image Memory**: Monitor image loading and caching

## Accessibility Testing

### VoiceOver Testing
```swift
class AccessibilityTests: XCTestCase {
    
    func test_collectionViewIsAccessible() {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let collectionView = app.collectionViews.firstMatch
        
        // Then
        XCTAssertTrue(collectionView.isAccessibilityElement)
        XCTAssertFalse(collectionView.label.isEmpty)
    }
}
```

### Accessibility Checklist
- **Labels**: All interactive elements have accessibility labels
- **Hints**: Complex elements have accessibility hints
- **Traits**: Proper accessibility traits are set
- **Navigation**: Logical navigation order
- **Dynamic Type**: Support for text scaling
- **Color Contrast**: Sufficient contrast ratios

### Testing Tools
- **VoiceOver**: Built-in iOS screen reader
- **Accessibility Inspector**: Xcode accessibility debugging
- **Dynamic Type**: Test with different text sizes
- **Color Blindness**: Test with different color filters

---

*This testing guide is maintained by the Crown & Barrel development team. For questions about testing strategies or implementation, please create an issue or contact the development team.*
