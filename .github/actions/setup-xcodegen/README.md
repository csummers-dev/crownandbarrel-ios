# Setup XcodeGen Action

A comprehensive GitHub Action for installing and configuring XcodeGen with intelligent caching and multiple installation strategies.

## Features

- 🚀 **Multiple Installation Strategies**: Direct download, ARM64 Homebrew, standard Homebrew
- 💾 **Intelligent Caching**: Reduces installation time with smart cache management
- 🏗️ **Architecture Detection**: Automatic ARM64/Intel detection with optimized installation paths
- ⚡ **Performance Optimized**: Fastest installation method prioritized
- 🛡️ **Robust Error Handling**: Comprehensive fallback mechanisms
- 📊 **Detailed Logging**: Clear installation progress and debugging information
- 🔧 **Configurable**: Flexible inputs for various use cases

## Usage

### Basic Usage

```yaml
- name: Setup XcodeGen
  uses: ./.github/actions/setup-xcodegen
```

### Advanced Usage

```yaml
- name: Setup XcodeGen with custom configuration
  uses: ./.github/actions/setup-xcodegen
  with:
    version: 'latest'
    cache-key-suffix: 'custom-build'
    generate-project: 'true'
    installation-timeout: '15'
```

### Using Outputs

```yaml
- name: Setup XcodeGen
  id: xcodegen
  uses: ./.github/actions/setup-xcodegen

- name: Display installation info
  run: |
    echo "XcodeGen Version: ${{ steps.xcodegen.outputs.xcodegen-version }}"
    echo "Installation Method: ${{ steps.xcodegen.outputs.installation-method }}"
    echo "Cache Hit: ${{ steps.xcodegen.outputs.cache-hit }}"
    echo "XcodeGen Path: ${{ steps.xcodegen.outputs.xcodegen-path }}"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `version` | XcodeGen version to install | No | `latest` |
| `cache-key-suffix` | Custom suffix for cache key (useful for parallel jobs) | No | `''` |
| `generate-project` | Whether to run `xcodegen generate` after installation | No | `true` |
| `installation-timeout` | Timeout for installation in minutes | No | `10` |

### Input Details

#### `version`
- Supports specific versions (e.g., `2.38.0`) or `latest`
- When using `latest`, cache refreshes weekly to get updates
- Examples: `latest`, `2.38.0`, `2.37.0`

#### `cache-key-suffix`
- Useful for parallel jobs that might have different requirements
- Helps avoid cache conflicts in matrix builds
- Examples: `unit-tests`, `ui-tests`, `release-build`

#### `generate-project`
- Set to `false` if you only need XcodeGen installed but don't want to generate the project
- Requires `project.yml` to exist in the repository root
- Will fail if `project.yml` is not found

#### `installation-timeout`
- Prevents hanging installations
- Recommended: 10-15 minutes for most cases
- Increase for slower network connections

## Outputs

| Output | Description |
|--------|-------------|
| `xcodegen-version` | The installed XcodeGen version |
| `installation-method` | Method used for installation |
| `cache-hit` | Whether the installation was restored from cache |
| `xcodegen-path` | Path to the XcodeGen binary |

### Output Values

#### `installation-method`
- `pre-installed`: XcodeGen was already available
- `cache`: Restored from cache
- `direct-download`: Downloaded from GitHub releases (fastest)
- `homebrew-arm64`: Installed via ARM64 Homebrew
- `homebrew-standard`: Installed via standard Homebrew
- `failed`: All installation methods failed

#### `cache-hit`
- `true`: Installation was restored from cache
- `false`: Fresh installation was performed

## Installation Strategies

The action uses multiple installation strategies in priority order:

### 1. Pre-installed Check
Checks if XcodeGen is already available in the system PATH.

### 2. Cache Restoration
Attempts to restore XcodeGen from GitHub Actions cache:
- Checks multiple potential cache locations
- Verifies cached binary functionality
- Adds to PATH if restoration successful

### 3. Direct Download (Primary)
Downloads the official XcodeGen artifact bundle from GitHub releases:
- Fastest and most reliable method
- Works on all runner types
- Creates symlinks for future caching

### 4. ARM64 Homebrew (Apple Silicon)
For ARM64 runners, attempts installation via Homebrew with architecture forcing:
- Tries multiple Homebrew paths
- Uses `arch -arm64` for compatibility
- Optimized for Apple Silicon runners

### 5. Standard Homebrew (Fallback)
Standard Homebrew installation as final fallback:
- Works on Intel-based runners
- Reliable but slower than direct download

## Caching Strategy

### Cache Key Format
```
{runner.os}-xcodegen-{version}-{architecture}-{suffix}
```

### Cache Paths
- `~/.local/bin/xcodegen` (symlink for direct downloads)
- `~/xcodegen/` (direct download extraction)
- `/opt/homebrew/bin/xcodegen` (ARM64 Homebrew)
- `/usr/local/bin/xcodegen` (Intel Homebrew)

### Cache Refresh
- `latest` version cache refreshes weekly
- Specific versions cache indefinitely
- Fallback keys provide partial cache hits

## Error Handling

### Comprehensive Fallbacks
- Multiple installation strategies prevent single points of failure
- Each strategy has independent error handling
- Detailed logging for debugging failed installations

### Timeout Protection
- Configurable timeout prevents hanging workflows
- Default 10-minute timeout for most use cases
- Logs system information on failure for debugging

### Verification Steps
- Verifies binary functionality after each installation attempt
- Checks PATH configuration and binary permissions
- Validates project generation requirements

## Performance

### Typical Installation Times
- **Cache hit**: ~5-10 seconds
- **Direct download**: ~30-60 seconds
- **Homebrew**: ~2-5 minutes

### Optimization Features
- Intelligent cache key management
- Weekly refresh for latest versions
- Symlink creation for consistent caching
- Architecture-specific optimizations

## Troubleshooting

### Common Issues

#### "project.yml not found"
- Ensure `project.yml` exists in repository root
- Set `generate-project: false` if you don't need project generation

#### "All installation strategies failed"
- Check network connectivity
- Verify runner has required tools (curl, unzip)
- Check GitHub rate limits for releases API

#### "Cache hit but no working XcodeGen found"
- Cache may be corrupted
- Action will automatically fall back to fresh installation
- Consider using a different `cache-key-suffix`

### Debug Information
The action provides comprehensive debug information on failure:
- System architecture detection
- Available tools (curl, unzip, brew)
- PATH configuration
- Installation attempt details

## Examples

### Matrix Build with Cache Isolation
```yaml
strategy:
  matrix:
    test-type: [unit, ui, integration]

steps:
  - name: Setup XcodeGen
    uses: ./.github/actions/setup-xcodegen
    with:
      cache-key-suffix: ${{ matrix.test-type }}
```

### Skip Project Generation
```yaml
- name: Setup XcodeGen (tool only)
  uses: ./.github/actions/setup-xcodegen
  with:
    generate-project: false
```

### Version Pinning
```yaml
- name: Setup XcodeGen (specific version)
  uses: ./.github/actions/setup-xcodegen
  with:
    version: '2.38.0'
```

### Extended Timeout for Slow Networks
```yaml
- name: Setup XcodeGen (extended timeout)
  uses: ./.github/actions/setup-xcodegen
  with:
    installation-timeout: '20'
```

## Contributing

When modifying this action:

1. Test on both ARM64 and Intel runners
2. Verify caching behavior with different scenarios
3. Update documentation for any new inputs/outputs
4. Test error handling and fallback mechanisms
5. Validate performance impact of changes

## License

This action is part of the Crown & Barrel iOS project and follows the same licensing terms.
