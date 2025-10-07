# CI/CD Pipeline Quick Reference

## Emergency Commands

### Validate All Workflows
```bash
./test_security_pipeline.sh
```

### Check YAML Syntax
```bash
find .github/workflows -name "*.yml" -exec python3 -c "import yaml; yaml.safe_load(open('{}'))" \;
```

### Check Workflow Structure
```bash
grep -l "name:" .github/workflows/*.yml
grep -l "on:" .github/workflows/*.yml
grep -l "jobs:" .github/workflows/*.yml
```

## Critical Security Fixes

### SARIF Upload Fix
```yaml
permissions:
  security-events: write  # Required for SARIF upload
```

### TruffleHog Fix
```yaml
- name: Run TruffleHog secret scanner
  uses: trufflesecurity/trufflehog@v3.90.8
  continue-on-error: true
  with:
    path: ./
    extra_args: --debug --only-verified filesystem
```

### Python Environment Fix
```yaml
- name: Install security tools
  run: |
    pipx install semgrep
    pipx install safety
    pipx install bandit
```

## Workflow Files

| File | Purpose | Trigger |
|------|---------|---------|
| `ci.yml` | Main CI pipeline | Push, PR |
| `ios-ci.yml` | Fast iOS feedback | Push, PR |
| `security.yml` | Security scanning | Push, Schedule |
| `security-audit.yml` | Security auditing | Schedule, Manual |
| `validate.yml` | Code validation | Push, PR |
| `performance-monitor.yml` | Performance monitoring | Push, Schedule |
| `release.yml` | Release management | Tags, Manual |
| `dependency-update.yml` | Dependency updates | Schedule, Manual |

## Action Versions

| Action | Version | Status |
|--------|---------|--------|
| `actions/checkout` | v4 | ✅ Stable |
| `maxim-lobanov/setup-xcode` | v1 | ✅ Stable |
| `aquasecurity/trivy-action` | 0.32.0 | ✅ Stable |
| `github/codeql-action/*` | v3 | ✅ Stable |
| `trufflesecurity/trufflehog` | v3.90.8 | ✅ Stable |

## Common Issues & Quick Fixes

### SARIF Upload Fails
**Error**: "Resource not accessible by integration"
**Fix**: Add `security-events: write` to permissions

### TruffleHog Fails
**Error**: "BASE and HEAD commits are the same"
**Fix**: Use `filesystem` in extra_args

### Python Tools Fail
**Error**: "externally-managed-environment"
**Fix**: Use `pipx` instead of `pip`

### Xcode Version Issues
**Error**: "Xcode version not found"
**Fix**: Use `latest-stable` instead of specific versions

### iOS Simulator Issues
**Error**: "Simulator not available"
**Fix**: Use supported iOS versions (18.2, 18.1, 17.5)

## Validation Checklist

- [ ] YAML syntax valid
- [ ] Workflow structure complete
- [ ] Security tools configured
- [ ] Error handling enabled
- [ ] Permissions set correctly
- [ ] Action versions stable
- [ ] Local testing passed

## Monitoring Commands

### Check Pipeline Status
```bash
gh run list --limit 5
```

### View Workflow Logs
```bash
gh run view <run-id>
```

### Check Security Alerts
```bash
gh api repos/:owner/:repo/dependabot/alerts
```

### Monitor Performance
```bash
gh api repos/:owner/:repo/actions/workflows/:workflow_id/runs --jq '.workflow_runs[0:5]'
```

## Maintenance Schedule

### Daily
- Monitor pipeline status
- Check security results

### Weekly
- Review security audits
- Check dependency updates

### Monthly
- Update action versions
- Review performance metrics

### Quarterly
- Comprehensive review
- Documentation updates

## Emergency Contacts

- **DevOps Team**: [Contact Info]
- **Security Team**: [Contact Info]
- **On-call Engineer**: [Contact Info]

## Useful Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)
- [Maintenance Guide](./DEVOPS_MAINTENANCE.md)

---

*Quick Reference Version: 1.0*
*Last Updated: $(date)*
