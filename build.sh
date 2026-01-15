#!/bin/bash
#
# build.sh - Build EndoscopeViewer for distribution
#
# Usage:
#   ./build.sh [debug|release]
#
# This script builds the EndoscopeViewer application and prepares it for distribution.

set -e

# Configuration
PROJECT_NAME="EndoscopeViewer"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
SCHEME_NAME="EndoscopeViewer"
CONFIGURATION="${1:-Release}"

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

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    log_error "Xcode command line tools are not installed"
    log_info "Install with: xcode-select --install"
    exit 1
fi

log_info "Starting build process..."
log_info "Configuration: ${CONFIGURATION}"
log_info "Project: ${PROJECT_NAME}"

# Clean previous builds
if [ -d "${BUILD_DIR}" ]; then
    log_info "Cleaning previous build directory..."
    rm -rf "${BUILD_DIR}"
fi

# Create build directory
mkdir -p "${BUILD_DIR}"

# Build the application
log_info "Building ${PROJECT_NAME}..."

xcodebuild \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -derivedDataPath "${BUILD_DIR}/DerivedData" \
    clean build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Check if build succeeded
if [ $? -eq 0 ]; then
    log_success "Build completed successfully!"
else
    log_error "Build failed!"
    exit 1
fi

# Find the built app
APP_PATH="${BUILD_DIR}/DerivedData/Build/Products/${CONFIGURATION}/${PROJECT_NAME}.app"

if [ ! -d "${APP_PATH}" ]; then
    log_error "Built application not found at ${APP_PATH}"
    exit 1
fi

# Copy to build directory
log_info "Copying application to build directory..."
cp -R "${APP_PATH}" "${BUILD_DIR}/"

# Create a zip archive
log_info "Creating zip archive..."
cd "${BUILD_DIR}"
zip -r "${PROJECT_NAME}.zip" "${PROJECT_NAME}.app" -q

# Calculate sizes
APP_SIZE=$(du -sh "${PROJECT_NAME}.app" | cut -f1)
ZIP_SIZE=$(du -sh "${PROJECT_NAME}.zip" | cut -f1)

log_success "Build complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Build Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Application:  ${BUILD_DIR}/${PROJECT_NAME}.app"
echo "  App Size:     ${APP_SIZE}"
echo "  Archive:      ${BUILD_DIR}/${PROJECT_NAME}.zip"
echo "  Archive Size: ${ZIP_SIZE}"
echo "  Configuration: ${CONFIGURATION}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "To install: Copy ${PROJECT_NAME}.app to /Applications"
log_info "To distribute: Use ${PROJECT_NAME}.zip or run ./create-dmg.sh"
