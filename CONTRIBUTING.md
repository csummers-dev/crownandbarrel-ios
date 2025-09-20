# Contributing to Crown & Barrel

Thank you for your interest in contributing to Crown & Barrel! This guide will help you get started with contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)
- [Types of Contributions](#types-of-contributions)

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct:

- **Be respectful** - Treat everyone with respect and kindness
- **Be constructive** - Provide helpful feedback and suggestions
- **Be patient** - Remember that everyone is learning and growing
- **Be collaborative** - Work together towards common goals

## Getting Started

### Prerequisites
- macOS with Xcode 16+
- Git installed and configured
- Basic knowledge of Swift and SwiftUI
- Familiarity with iOS development

### Initial Setup
1. **Fork the repository** on GitLab
2. **Clone your fork** locally:
   ```bash
   git clone https://gitlab.com/YOUR_USERNAME/crown-and-barrel.git
   cd crown-and-barrel
   ```
3. **Set up the development environment** following the [Development Guide](DEVELOPMENT.md)
4. **Verify everything works** by building and running the app

## Development Workflow

### Branch Strategy
- **Main branch**: `main` - contains stable, release-ready code
- **Feature branches**: `feature/description` - for new features
- **Bug fix branches**: `bugfix/description` - for bug fixes
- **Hotfix branches**: `hotfix/description` - for critical fixes

### Creating a Feature Branch
```bash
# Start from main branch
git checkout main
git pull origin main

# Create and switch to new branch
git checkout -b feature/your-feature-name

# Make your changes
# ... code changes ...

# Commit your changes
git add .
git commit -m "Add feature: brief description"
```

### Commit Message Guidelines
Use clear, descriptive commit messages:

```
feat: add dark mode toggle to settings
fix: resolve image loading issue in collection view
docs: update contributing guidelines
test: add unit tests for watch repository
refactor: simplify theme manager implementation
```

**Format**: `<type>: <description>`

**Types**:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `test`: Test additions or changes
- `refactor`: Code refactoring
- `style`: Code style changes
- `perf`: Performance improvements
- `chore`: Maintenance tasks

## Code Standards

### Swift Style Guidelines
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for automated style checking
- Write self-documenting code with clear variable and function names
- Add comments for complex logic and business rules

### SwiftUI Best Practices
- Keep views small and focused on a single responsibility
- Use proper state management (`@State`, `@ObservedObject`, `@StateObject`)
- Implement accessibility features (VoiceOver, Dynamic Type)
- Follow the established design system patterns

### Architecture Guidelines
- Follow the MVVM + Repository pattern established in the project
- Keep business logic in ViewModels, not in Views
- Use protocols for abstractions and testability
- Maintain separation of concerns between layers

### Code Review Checklist
Before submitting a pull request, ensure:

- [ ] Code follows established style guidelines
- [ ] All tests pass
- [ ] New features have appropriate tests
- [ ] Documentation is updated if needed
- [ ] No hardcoded values or magic numbers
- [ ] Proper error handling is implemented
- [ ] Accessibility features are included
- [ ] Performance considerations are addressed

## Testing Requirements

### Unit Tests
- Write unit tests for all business logic
- Test edge cases and error conditions
- Use descriptive test names that explain the scenario
- Aim for high test coverage on critical paths

### UI Tests
- Write UI tests for user flows
- Test theme switching functionality
- Verify form validation works correctly
- Test navigation between screens

### Running Tests
```bash
# Run all tests
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run specific test target
xcodebuild -project CrownAndBarrel.xcodeproj -scheme CrownAndBarrel -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CrownAndBarrelTests
```

### Test Guidelines
- Tests should be independent and not rely on external state
- Use descriptive test names: `test_whenUserTapsAddWatch_thenWatchFormIsPresented()`
- Mock external dependencies
- Test both success and failure scenarios

## Pull Request Process

### Before Submitting
1. **Ensure tests pass** - All tests must pass before submitting
2. **Update documentation** - Update relevant documentation
3. **Check for conflicts** - Rebase on latest main branch if needed
4. **Self-review** - Review your own code before submitting

### Creating a Pull Request
1. **Push your branch** to your fork
2. **Create a pull request** on GitLab
3. **Fill out the PR template** with relevant information
4. **Link related issues** if applicable
5. **Request review** from maintainers

### Pull Request Template
```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] UI tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Review Process
- Maintainers will review your pull request
- Address any feedback or requested changes
- Be responsive to review comments
- Keep the PR focused and manageable in size

## Issue Guidelines

### Reporting Bugs
When reporting bugs, include:

- **Environment**: macOS version, Xcode version, iOS version
- **Steps to reproduce**: Detailed steps to reproduce the issue
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Screenshots**: If applicable
- **Error logs**: Any error messages or logs

### Feature Requests
When requesting features:

- **Clear description**: What feature you'd like to see
- **Use case**: Why this feature would be valuable
- **Mockups/wireframes**: If you have design ideas
- **Priority**: How important this feature is to you

### Good Issue Examples
- Clear, descriptive title
- Detailed description with context
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Relevant labels and milestones

## Types of Contributions

### Code Contributions
- **Bug fixes**: Fix issues and improve stability
- **New features**: Add functionality requested by users
- **Performance improvements**: Optimize existing code
- **Refactoring**: Improve code quality and maintainability

### Documentation Contributions
- **README updates**: Improve project documentation
- **Code comments**: Add helpful comments to complex code
- **Architecture docs**: Update architecture documentation
- **Tutorial guides**: Create guides for new contributors

### Testing Contributions
- **Unit tests**: Add tests for untested code
- **UI tests**: Add tests for user flows
- **Test improvements**: Improve existing tests
- **Test documentation**: Document testing practices

### Design Contributions
- **UI/UX improvements**: Enhance user interface
- **Accessibility**: Improve accessibility features
- **Design system**: Contribute to design tokens
- **Iconography**: Add or improve icons

## Getting Help

### Resources
- **Development Guide**: [DEVELOPMENT.md](DEVELOPMENT.md)
- **Architecture Guide**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Troubleshooting Guide**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### Communication
- **GitLab Issues**: For bug reports and feature requests
- **GitLab Discussions**: For questions and general discussion
- **Email**: [csummersdev@icloud.com](mailto:csummersdev@icloud.com)

### Mentorship
New contributors are welcome! Don't hesitate to:
- Ask questions in issues or discussions
- Request help with your first contribution
- Ask for code review and feedback

## Recognition

Contributors will be recognized in:
- **Contributors list** in the README
- **Release notes** for significant contributions
- **Git commit history** for all contributions

Thank you for contributing to Crown & Barrel! Your contributions help make this project better for everyone.

---

*This contributing guide is maintained by the Crown & Barrel development team. For questions or suggestions about contributing, please create an issue or contact the development team.*
