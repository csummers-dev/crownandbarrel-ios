# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| 0.9.x   | :white_check_mark: |
| 0.8.x   | :x:                |
| < 0.8   | :x:                |

## Reporting a Vulnerability

We take security bugs seriously. We appreciate your efforts to responsibly disclose your findings, and will make every effort to acknowledge your contributions.

### How to Report a Security Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **security@crownandbarrel.app**

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

### What to Include

Please include the following information in your report:

- **Type of issue** (e.g. buffer overflow, SQL injection, cross-site scripting, etc.)
- **Full paths** of source file(s) related to the manifestation of the issue
- **Location** of the affected source code (tag/branch/commit or direct URL)
- **Special configuration** required to reproduce the issue
- **Step-by-step instructions** to reproduce the issue
- **Proof-of-concept or exploit code** (if possible)
- **Impact** of the issue, including how an attacker might exploit it

### What to Expect

After you submit a report, we will:

1. **Confirm receipt** of your vulnerability report within 48 hours
2. **Provide regular updates** on our progress
3. **Credit you** in our security advisories (unless you prefer to remain anonymous)

## Security Measures

### Code Security

- **Static Analysis**: We use SwiftLint and custom validation scripts to identify potential security issues
- **Dependency Scanning**: Automated vulnerability scanning with Trivy and CodeQL
- **Code Reviews**: All code changes require review before merging
- **Secure Coding Practices**: Following OWASP guidelines for secure development

### Infrastructure Security

- **GitHub Actions Security**: All workflows use pinned action versions and minimal permissions
- **Secrets Management**: Sensitive data stored in GitHub Secrets with proper access controls
- **Branch Protection**: Protected branches with required status checks
- **Dependency Updates**: Automated security updates via Dependabot

### Data Security

- **Local-First Storage**: All user data stored locally on device
- **No Network Communication**: App does not transmit data to external services
- **Encryption**: Core Data uses iOS built-in encryption
- **Backup Security**: User controls backup creation and storage

## Security Advisories

Security advisories will be published in the following locations:

- **GitHub Security Advisories**: https://github.com/csummers-dev/crownandbarrel-ios/security/advisories
- **Release Notes**: Included in app update release notes
- **Email Notifications**: For critical vulnerabilities (if you've subscribed)

## Responsible Disclosure

We follow responsible disclosure practices:

- **90-day disclosure deadline**: We aim to resolve security issues within 90 days
- **Coordination**: We work with security researchers to coordinate disclosure
- **Credit**: We credit security researchers in our advisories (unless they prefer anonymity)
- **No legal action**: We will not pursue legal action against security researchers acting in good faith

## Security Best Practices for Users

### App Security

- **Keep iOS Updated**: Always use the latest iOS version for security patches
- **App Updates**: Install app updates promptly to receive security fixes
- **Backup Security**: Store backup files in secure locations
- **Device Security**: Use device passcode/biometric authentication

### Data Protection

- **Backup Encryption**: Enable device backup encryption in iOS Settings
- **Secure Storage**: Store backup files in encrypted cloud storage if desired
- **Access Control**: Limit device access to trusted individuals
- **Regular Backups**: Create regular backups of your watch collection data

## Security Tools and Processes

### Automated Security Scanning

- **CodeQL**: Static analysis for security vulnerabilities
- **Trivy**: Container and dependency vulnerability scanning
- **TruffleHog**: Secret detection and prevention
- **Dependabot**: Automated dependency updates for security patches

### Security Testing

- **Unit Tests**: Security-focused unit tests for critical functions
- **Integration Tests**: End-to-end security testing
- **Penetration Testing**: Regular security assessments
- **Vulnerability Assessment**: Periodic vulnerability scans

## Contact Information

- **Security Email**: security@crownandbarrel.app
- **Developer Email**: csummersdev@icloud.com
- **GitHub Issues**: For non-security bugs and feature requests
- **GitHub Discussions**: For general questions and community discussions

## Acknowledgments

We thank the security researchers and community members who help keep Crown & Barrel secure:

- Security researchers who responsibly disclose vulnerabilities
- Community members who report security concerns
- Contributors who help improve security practices
- Users who provide feedback on security features

---

**Last Updated**: January 2025  
**Next Review**: July 2025
