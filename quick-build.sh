#!/bin/bash
#
# quick-build.sh - Quick build and package script
#
# This script builds the app and creates both ZIP and DMG distributions.

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  EndoscopeViewer - Quick Build & Package"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

# Get version from user or use default
read -p "Enter version number (default: 1.0): " VERSION
VERSION=${VERSION:-1.0}

echo ""
echo -e "${BLUE}[1/3]${NC} Building application..."
./build.sh Release

echo ""
echo -e "${BLUE}[2/3]${NC} Creating DMG installer..."
./create-dmg.sh "${VERSION}"

echo ""
echo -e "${GREEN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Build Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"
echo ""
echo "Distribution files created:"
echo "  • build/EndoscopeViewer.app - Application bundle"
echo "  • build/EndoscopeViewer.zip - ZIP archive"
echo "  • build/EndoscopeViewer-${VERSION}.dmg - DMG installer"
echo ""
echo "To test locally:"
echo "  open build/EndoscopeViewer.app"
echo ""
echo "To install:"
echo "  1. Open the DMG file"
echo "  2. Drag EndoscopeViewer.app to Applications"
echo ""
