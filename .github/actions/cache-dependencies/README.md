# Cache Dependencies Action

A centralized caching strategy for all types of dependencies with intelligent cache management and performance optimization.

## Features

- 🎯 **Multiple Cache Types**: Pre-configured for common dependency types
- 🔑 **Smart Key Management**: Automatic cache key generation with fallbacks
- 📊 **Cache Analytics**: Size information and hit rate monitoring
- ⚡ **Performance Optimized**: Intelligent restore key strategies
- 🛠️ **Extensible**: Custom cache configurations supported
- 🔄 **Fallback Strategy**: Multiple restore keys for maximum cache utilization

## Supported Cache Types

| Type | Description | Cached Paths |
|------|-------------|--------------|
| `xcodegen` | XcodeGen binaries and installations | `~/.local/bin/xcodegen`, `~/xcodegen/`, Homebrew paths |
| `swiftlint` | SwiftLint binaries | `~/.local/bin/swiftlint`, Homebrew paths |
| `pip` | Python packages | `~/.cache/pip`, `~/.local/lib/python*/site-packages` |
| `npm` | Node.js packages | `~/.npm`, `node_modules` |
| `gem` | Ruby gems | `~/.gem`, `vendor/bundle` |
| `swift-packages` | Swift Package Manager | `.build`, DerivedData SourcePackages, SwiftPM cache |
| `derived-data` | Xcode DerivedData | `~/Library/Developer/Xcode/DerivedData` |
| `homebrew` | Homebrew cache | Homebrew cache directories |
| `custom` | Custom paths | User-specified paths |

## Usage

### Basic Usage

```yaml
- name: Cache XcodeGen
  uses: ./.github/actions/cache-dependencies
  with:
    cache-type: 'xcodegen'
```

### Advanced Configuration

```yaml
- name: Cache Swift Packages
  uses: ./.github/actions/cache-dependencies
  with:
    cache-type: 'swift-packages'
    cache-key: 'v2-${{ hashFiles("Package.resolved") }}'
    restore-keys: |
      v1-
      v2-
    cache-suffix: 'release-build'
```

### Custom Cache Paths

```yaml
- name: Cache Custom Dependencies
  uses: ./.github/actions/cache-dependencies
  with:
    cache-type: 'custom'
    cache-key: 'my-deps-${{ hashFiles("**/deps.lock") }}'
    custom-paths: |
      ./custom-cache/
      ./build-artifacts/
      ~/.my-tool-cache
```

### Using Outputs

```yaml
- name: Cache Dependencies
  id: cache-deps
  uses: ./.github/actions/cache-dependencies
  with:
    cache-type: 'pip'
    cache-key: 'requirements-${{ hashFiles("requirements.txt") }}'

- name: Install dependencies
  if: steps.cache-deps.outputs.cache-hit != 'true'
  run: pip install -r requirements.txt

- name: Display cache info
  run: |
    echo "Cache Hit: ${{ steps.cache-deps.outputs.cache-hit }}"
    echo "Cache Key: ${{ steps.cache-deps.outputs.cache-key }}"
    echo "Cache Size: ${{ steps.cache-deps.outputs.cache-size }}"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `cache-type` | Type of cache to manage | Yes | - |
| `cache-key` | Primary cache key | No | `default` |
| `restore-keys` | Fallback cache keys (newline separated) | No | `''` |
| `custom-paths` | Custom paths to cache (for `cache-type: custom`) | No | `''` |
| `cache-suffix` | Additional suffix for cache key isolation | No | `''` |

### Input Details

#### `cache-type`
Must be one of the supported types:
- `xcodegen` - XcodeGen binaries
- `swiftlint` - SwiftLint binaries
- `pip` - Python packages
- `npm` - Node.js packages
- `gem` - Ruby gems
- `swift-packages` - Swift Package Manager dependencies
- `derived-data` - Xcode build artifacts
- `homebrew` - Homebrew cache
- `custom` - User-defined paths

#### `cache-key`
- Should include version identifiers or file hashes for dependency tracking
- Examples: `v1`, `${{ hashFiles('Package.resolved') }}`, `xcode-16.0`
- Will be prefixed with `{runner.os}-{cache-type}-`

#### `restore-keys`
- Newline-separated list of fallback keys
- Useful for partial cache hits when dependencies change
- Will be prefixed with `{runner.os}-{cache-type}-`

#### `custom-paths`
- Only used when `cache-type: custom`
- Newline-separated list of paths to cache
- Supports both files and directories
- Can use shell glob patterns

#### `cache-suffix`
- Useful for isolating caches between different jobs or configurations
- Examples: `unit-tests`, `release`, `debug`
- Added to the end of the cache key

## Outputs

| Output | Description |
|--------|-------------|
| `cache-hit` | Whether the cache was restored (`true`/`false`) |
| `cache-key` | The actual cache key used |
| `cache-size` | Approximate cache size information |

### Output Examples

#### `cache-hit`
- `true` - Cache was restored successfully
- `false` - No cache found, will create new cache entry

#### `cache-key`
Example: `macOS-xcodegen-v1-${{ hashFiles('project.yml') }}-release`

#### `cache-size`
Example output:
```
~/.local/bin/xcodegen: 15MB
~/xcodegen/: 45MB
/opt/homebrew/bin/xcodegen: 12MB
```

## Cache Key Strategy

### Key Format
```
{runner.os}-{cache-type}-{cache-key}-{cache-suffix}
```

### Examples
- Basic: `macOS-xcodegen-default`
- With hash: `macOS-swift-packages-a1b2c3d4`
- With suffix: `macOS-pip-requirements-abc123-unit-tests`

### Restore Key Hierarchy
1. Exact match: Full cache key
2. User-provided restore keys (prefixed)
3. Default fallback: `{runner.os}-{cache-type}-{cache-key}`
4. Broad fallback: `{runner.os}-{cache-type}-`

## Performance Benefits

### Cache Hit Scenarios
- **Full Hit**: Exact cache key match - maximum performance
- **Partial Hit**: Restore key match - good performance with incremental updates
- **Miss**: No cache - full rebuild but creates cache for future runs

### Typical Performance Improvements
- **XcodeGen**: 30-60 seconds → 5-10 seconds
- **SwiftLint**: 2-5 minutes → 5-10 seconds
- **Swift Packages**: 1-3 minutes → 10-30 seconds
- **Pip Dependencies**: 30-120 seconds → 5-15 seconds

## Examples

### iOS Development Workflow
```yaml
name: iOS CI

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      # Cache XcodeGen
      - name: Cache XcodeGen
        uses: ./.github/actions/cache-dependencies
        with:
          cache-type: 'xcodegen'
          cache-key: 'v1'
      
      # Cache Swift Packages
      - name: Cache Swift Packages
        uses: ./.github/actions/cache-dependencies
        with:
          cache-type: 'swift-packages'
          cache-key: '${{ hashFiles("Package.resolved") }}'
          restore-keys: |
            ${{ hashFiles("Package.swift") }}
            latest
      
      # Cache DerivedData for faster builds
      - name: Cache DerivedData
        uses: ./.github/actions/cache-dependencies
        with:
          cache-type: 'derived-data'
          cache-key: '${{ hashFiles("**/*.swift") }}'
          restore-keys: |
            ${{ hashFiles("Sources/**/*.swift") }}
            base
```

### Python Project Workflow
```yaml
- name: Cache Python Dependencies
  uses: ./.github/actions/cache-dependencies
  with:
    cache-type: 'pip'
    cache-key: '${{ hashFiles("requirements.txt", "requirements-dev.txt") }}'
    restore-keys: |
      ${{ hashFiles("requirements.txt") }}
      latest

- name: Install dependencies
  run: pip install -r requirements.txt -r requirements-dev.txt
```

### Multi-Platform Matrix
```yaml
strategy:
  matrix:
    os: [macos-latest, ubuntu-latest]
    cache-suffix: [unit-tests, integration-tests]

steps:
  - name: Cache Dependencies
    uses: ./.github/actions/cache-dependencies
    with:
      cache-type: 'pip'
      cache-key: '${{ hashFiles("requirements.txt") }}'
      cache-suffix: '${{ matrix.cache-suffix }}'
```

### Custom Cache Configuration
```yaml
- name: Cache Build Artifacts
  uses: ./.github/actions/cache-dependencies
  with:
    cache-type: 'custom'
    cache-key: 'build-${{ github.sha }}'
    custom-paths: |
      ./dist/
      ./build/
      ./.build-cache/
    restore-keys: |
      build-${{ github.ref_name }}
      build-main
```

## Best Practices

### 1. Use Specific Cache Keys
```yaml
# ✅ Good - includes file hash
cache-key: 'deps-${{ hashFiles("Package.resolved") }}'

# ❌ Avoid - too generic
cache-key: 'deps'
```

### 2. Provide Restore Keys
```yaml
# ✅ Good - multiple fallback options
restore-keys: |
  deps-${{ hashFiles("Package.swift") }}
  deps-main
  deps-

# ❌ Avoid - no fallbacks
restore-keys: ''
```

### 3. Use Cache Suffixes for Isolation
```yaml
# ✅ Good - isolates test vs release caches
cache-suffix: '${{ matrix.build-type }}'

# ❌ Avoid - shared cache between incompatible builds
cache-suffix: ''
```

### 4. Monitor Cache Performance
```yaml
- name: Cache Dependencies
  id: cache
  uses: ./.github/actions/cache-dependencies
  with:
    cache-type: 'swift-packages'

- name: Log Cache Performance
  run: |
    echo "Cache hit: ${{ steps.cache.outputs.cache-hit }}"
    if [[ "${{ steps.cache.outputs.cache-hit }}" != "true" ]]; then
      echo "Cache miss - consider updating cache key strategy"
    fi
```

## Troubleshooting

### Common Issues

#### "Unsupported cache type"
- Verify the `cache-type` is one of the supported types
- Check for typos in the cache type name
- Use `custom` for unsupported dependency types

#### "Custom cache type requires custom-paths"
- When using `cache-type: custom`, you must provide `custom-paths`
- Ensure paths are newline-separated
- Verify paths exist and are accessible

#### Poor cache hit rate
- Review cache key strategy - may be too specific
- Add appropriate restore keys for partial hits
- Consider using file hashes for dependency tracking

#### Cache size too large
- Review cached paths - may be including unnecessary files
- Consider using more specific paths
- Use `.gitignore` patterns to exclude temporary files

### Debug Information

The action provides comprehensive logging:
- Cache key generation process
- Path resolution for each cache type
- Cache hit/miss status
- Size information for cached items
- Performance impact analysis

## Contributing

When extending this action:

1. **Adding New Cache Types**:
   - Add case to `paths` step
   - Update documentation with new type
   - Test with typical usage scenarios
   - Consider cross-platform compatibility

2. **Modifying Cache Strategies**:
   - Test impact on existing workflows
   - Verify backward compatibility
   - Update examples and documentation
   - Benchmark performance changes

3. **Testing**:
   - Test cache hit and miss scenarios
   - Verify restore key fallback behavior
   - Test with different runner types
   - Validate size reporting accuracy

## Dependencies

This action uses:
- [`actions/cache@v4`](https://github.com/actions/cache) - Core caching functionality

## License

This action is part of the Crown & Barrel iOS project and follows the same licensing terms.
