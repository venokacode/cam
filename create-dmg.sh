#!/bin/bash
#
# create-dmg.sh - Create a DMG installer for EndoscopeViewer
#
# Usage:
#   ./create-dmg.sh [version]
#
# This script creates a distributable DMG file for the EndoscopeViewer application.

set -e

# Configuration
PROJECT_NAME="EndoscopeViewer"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
VERSION="${1:-1.0}"
DMG_NAME="${PROJECT_NAME}-${VERSION}"
VOLUME_NAME="${PROJECT_NAME} ${VERSION}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This script must be run on macOS"
    exit 1
fi

# Check if app exists
APP_PATH="${BUILD_DIR}/${PROJECT_NAME}.app"
if [ ! -d "${APP_PATH}" ]; then
    log_error "Application not found at ${APP_PATH}"
    log_info "Run ./build.sh first to build the application"
    exit 1
fi

log_info "Creating DMG installer for ${PROJECT_NAME} v${VERSION}..."

# Create temporary directory for DMG contents
TMP_DIR="${BUILD_DIR}/dmg_temp"
if [ -d "${TMP_DIR}" ]; then
    rm -rf "${TMP_DIR}"
fi
mkdir -p "${TMP_DIR}"

# Copy app to temporary directory
log_info "Copying application..."
cp -R "${APP_PATH}" "${TMP_DIR}/"

# Create symlink to Applications folder
log_info "Creating Applications symlink..."
ln -s /Applications "${TMP_DIR}/Applications"

# Create README for DMG
log_info "Creating installation instructions..."
cat > "${TMP_DIR}/README.txt" << 'EOF'
EndoscopeViewer - macOS UVC Dental Endoscope Viewer
===================================================

Installation Instructions:
--------------------------
1. Drag "EndoscopeViewer.app" to the "Applications" folder
2. Open "EndoscopeViewer" from your Applications folder
3. Grant camera permissions when prompted
4. Connect your UVC endoscope and start viewing!

Requirements:
-------------
- macOS 12.0 (Monterey) or later
- UVC-compatible camera or endoscope

Features:
---------
- Low-latency live preview
- Still photo capture (JPEG)
- Multiple format support (MJPEG, YUV422)
- AMCap-style format selection
- Automatic window sizing

First Launch:
-------------
On first launch, macOS may display a security warning because
the app is not from an identified developer. To open:

1. Right-click (or Control-click) on the app
2. Select "Open" from the context menu
3. Click "Open" in the security dialog

Alternatively, go to:
System Settings → Privacy & Security → Allow apps from...

Troubleshooting:
----------------
- If camera doesn't appear: Check USB connection and permissions
- If preview is black: Close other apps using the camera
- For support: Check README.md in the project repository

Version: 1.0
License: See LICENSE file
EOF

# Remove any existing DMG
DMG_PATH="${BUILD_DIR}/${DMG_NAME}.dmg"
if [ -f "${DMG_PATH}" ]; then
    log_warning "Removing existing DMG..."
    rm "${DMG_PATH}"
fi

# Create DMG
log_info "Creating disk image..."
hdiutil create \
    -volname "${VOLUME_NAME}" \
    -srcfolder "${TMP_DIR}" \
    -ov \
    -format UDZO \
    -fs HFS+ \
    "${DMG_PATH}"

# Verify DMG was created
if [ -f "${DMG_PATH}" ]; then
    DMG_SIZE=$(du -sh "${DMG_PATH}" | cut -f1)
    log_success "DMG created successfully!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  DMG Installer Created"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  File:    ${DMG_NAME}.dmg"
    echo "  Size:    ${DMG_SIZE}"
    echo "  Version: ${VERSION}"
    echo "  Path:    ${DMG_PATH}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "To test: Double-click the DMG file and drag app to Applications"
    log_info "To distribute: Share the ${DMG_NAME}.dmg file"
else
    log_error "Failed to create DMG"
    exit 1
fi

# Clean up temporary directory
log_info "Cleaning up..."
rm -rf "${TMP_DIR}"

log_success "Done! DMG installer is ready for distribution."
