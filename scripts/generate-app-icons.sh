#!/bin/bash

#
# App Icon Generation Script
# Generates all required iOS app icon sizes from master 1024x1024 images
# Supports both light and dark mode variants
#
# Master Image Requirements:
# - Light mode: AppIcon-1024.png (1024x1024 pixels)
# - Dark mode: AppIcon-1024-dark.png (1024x1024 pixels)
#
# Usage: ./scripts/generate-app-icons.sh
# Requirements: ImageMagick (brew install imagemagick)
#
# CRITICAL: This script generates dark mode variants for all sizes EXCEPT marketing (1024x1024)
# Marketing icons do NOT support dark mode variants in iOS asset catalogs
# Removing this script or changing the naming convention will cause build failures
#

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ICON_DIR="$PROJECT_ROOT/AppResources/Assets.xcassets/AppIcon.appiconset"

# Master image paths
LIGHT_MASTER="$ICON_DIR/AppIcon-1024.png"
DARK_MASTER="$ICON_DIR/AppIcon-1024-dark.png"

# Icon size definitions (matches AppIconSize.swift)
# Format: "filename:size"
ICON_SIZES=(
    "Icon-20@2x:40x40"
    "Icon-20@3x:60x60"
    "Icon-29@2x:58x58"
    "Icon-29@3x:87x87"
    "Icon-40@2x:80x80"
    "Icon-40@3x:120x120"
    "Icon-60@2x:120x120"
    "Icon-60@3x:180x180"
)

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if ImageMagick is installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v convert &> /dev/null; then
        print_error "ImageMagick is not installed. Please install it with: brew install imagemagick"
        exit 1
    fi
    
    print_success "ImageMagick is installed"
}

# Function to validate master images
validate_master_images() {
    print_status "Validating master images..."
    
    if [ ! -f "$LIGHT_MASTER" ]; then
        print_error "Light mode master image not found: $LIGHT_MASTER"
        exit 1
    fi
    
    if [ ! -f "$DARK_MASTER" ]; then
        print_error "Dark mode master image not found: $DARK_MASTER"
        exit 1
    fi
    
    # Check if images are 1024x1024
    LIGHT_SIZE=$(identify -format "%wx%h" "$LIGHT_MASTER" 2>/dev/null || echo "unknown")
    DARK_SIZE=$(identify -format "%wx%h" "$DARK_MASTER" 2>/dev/null || echo "unknown")
    
    if [ "$LIGHT_SIZE" != "1024x1024" ]; then
        print_error "Light mode master image is not 1024x1024 (found: $LIGHT_SIZE)"
        exit 1
    fi
    
    if [ "$DARK_SIZE" != "1024x1024" ]; then
        print_error "Dark mode master image is not 1024x1024 (found: $DARK_SIZE)"
        exit 1
    fi
    
    print_success "Master images validated"
    print_status "Light mode: $LIGHT_SIZE"
    print_status "Dark mode: $DARK_SIZE"
}

# Function to generate icon sizes
generate_icon() {
    local base_name="$1"
    local size="$2"
    local source_image="$3"
    local output_path="$4"
    
    print_status "Generating $base_name ($size) from $(basename "$source_image")"
    
    # Generate the icon with high quality settings
    convert "$source_image" \
        -resize "${size}!" \
        -unsharp 0x0.75+0.75+0.008 \
        -quality 100 \
        "$output_path"
    
    if [ $? -eq 0 ]; then
        print_success "Generated $base_name"
    else
        print_error "Failed to generate $base_name"
        exit 1
    fi
}

# Function to generate all icons for a theme
generate_theme_icons() {
    local theme="$1"
    local master_image="$2"
    local theme_suffix="$3"
    
    print_status "Generating $theme theme icons..."
    
    # Generate all required sizes
    for icon_spec in "${ICON_SIZES[@]}"; do
        IFS=':' read -r icon_name size <<< "$icon_spec"
        local output_name="${icon_name}${theme_suffix}.png"
        local output_path="$ICON_DIR/$output_name"
        
        generate_icon "$output_name" "$size" "$master_image" "$output_path"
    done
    
    print_success "Completed $theme theme icon generation"
}

# Function to create backup of existing icons
create_backup() {
    print_status "Creating backup of existing icons..."
    
    local backup_dir="$ICON_DIR/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup existing icon files
    find "$ICON_DIR" -name "Icon-*.png" -type f -exec cp {} "$backup_dir/" \;
    
    if [ $? -eq 0 ]; then
        print_success "Backup created at: $backup_dir"
    else
        print_warning "Failed to create backup"
    fi
}

# Function to validate generated icons
validate_generated_icons() {
    print_status "Validating generated icons..."
    
    local missing_files=()
    
    # Check light mode icons
    for icon_spec in "${ICON_SIZES[@]}"; do
        IFS=':' read -r icon_name size <<< "$icon_spec"
        local light_file="$ICON_DIR/${icon_name}.png"
        local dark_file="$ICON_DIR/${icon_name}-dark.png"
        
        if [ ! -f "$light_file" ]; then
            missing_files+=("$light_file")
        fi
        
        if [ ! -f "$dark_file" ]; then
            missing_files+=("$dark_file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        print_success "All icons generated successfully"
    else
        print_error "Missing files:"
        for file in "${missing_files[@]}"; do
            print_error "  - $file"
        done
        exit 1
    fi
}

# Function to display summary
show_summary() {
    print_status "App Icon Generation Summary"
    echo "=================================="
    
    local total_icons=$((${#ICON_SIZES[@]} * 2))  # 2 themes
    local generated_count=0
    
    # Count generated files
    for icon_spec in "${ICON_SIZES[@]}"; do
        IFS=':' read -r icon_name size <<< "$icon_spec"
        local light_file="$ICON_DIR/${icon_name}.png"
        local dark_file="$ICON_DIR/${icon_name}-dark.png"
        
        if [ -f "$light_file" ]; then
            ((generated_count++))
        fi
        
        if [ -f "$dark_file" ]; then
            ((generated_count++))
        fi
    done
    
    print_success "Generated $generated_count of $total_icons required icons"
    
    echo ""
    print_status "Icon sizes generated:"
    for icon_spec in "${ICON_SIZES[@]}"; do
        IFS=':' read -r icon_name size <<< "$icon_spec"
        echo "  - $icon_name: ${size}px"
    done
    
    echo ""
    print_status "Next steps:"
    echo "  1. Update Contents.json with dark mode support"
    echo "  2. Test icons in Xcode and simulator"
    echo "  3. Verify icons display correctly on device"
}

# Main execution
main() {
    echo "=========================================="
    echo "    Crown & Barrel App Icon Generator"
    echo "=========================================="
    echo ""
    
    # Check dependencies
    check_dependencies
    
    # Validate master images
    validate_master_images
    
    # Create backup of existing icons
    create_backup
    
    # Generate light mode icons
    generate_theme_icons "Light" "$LIGHT_MASTER" ""
    
    # Generate dark mode icons
    generate_theme_icons "Dark" "$DARK_MASTER" "-dark"
    
    # Validate generated icons
    validate_generated_icons
    
    # Show summary
    show_summary
    
    print_success "App icon generation completed successfully!"
}

# Run main function
main "$@"
