# Makefile for EndoscopeViewer
# Simplifies building and distributing the macOS application

.PHONY: all help build debug release dmg clean install uninstall test open

# Default target
all: release dmg

# Help target - shows available commands
help:
	@echo "EndoscopeViewer - Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  make           - Build release and create DMG (default)"
	@echo "  make build     - Build debug version"
	@echo "  make debug     - Build debug version"
	@echo "  make release   - Build release version"
	@echo "  make dmg       - Create DMG installer (requires build first)"
	@echo "  make install   - Install to /Applications"
	@echo "  make uninstall - Remove from /Applications"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make test      - Open the built application"
	@echo "  make open      - Open project in Xcode"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "Version control:"
	@echo "  make VERSION=1.0 dmg  - Create DMG with specific version"
	@echo ""

# Build debug version
build: debug

debug:
	@echo "Building debug version..."
	@./build.sh Debug

# Build release version
release:
	@echo "Building release version..."
	@./build.sh Release

# Create DMG installer
dmg:
	@if [ ! -d "build/EndoscopeViewer.app" ]; then \
		echo "Error: Application not built. Run 'make release' first."; \
		exit 1; \
	fi
	@echo "Creating DMG installer..."
	@./create-dmg.sh $(VERSION)

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf build/
	@echo "Clean complete!"

# Install to /Applications
install:
	@if [ ! -d "build/EndoscopeViewer.app" ]; then \
		echo "Error: Application not built. Run 'make release' first."; \
		exit 1; \
	fi
	@echo "Installing to /Applications..."
	@cp -R build/EndoscopeViewer.app /Applications/
	@echo "Installation complete!"
	@echo "You can now launch EndoscopeViewer from Applications folder"

# Uninstall from /Applications
uninstall:
	@if [ -d "/Applications/EndoscopeViewer.app" ]; then \
		echo "Removing from /Applications..."; \
		rm -rf /Applications/EndoscopeViewer.app; \
		echo "Uninstallation complete!"; \
	else \
		echo "EndoscopeViewer is not installed in /Applications"; \
	fi

# Test - open the built application
test:
	@if [ ! -d "build/EndoscopeViewer.app" ]; then \
		echo "Error: Application not built. Run 'make release' first."; \
		exit 1; \
	fi
	@echo "Opening application..."
	@open build/EndoscopeViewer.app

# Open project in Xcode
open:
	@echo "Opening project in Xcode..."
	@open EndoscopeViewer.xcodeproj

# Quick build - build and package everything
quick: release dmg
	@echo ""
	@echo "✅ Quick build complete!"
	@echo ""
	@echo "Distribution files:"
	@ls -lh build/EndoscopeViewer.app build/EndoscopeViewer.zip build/EndoscopeViewer-*.dmg 2>/dev/null || true

# Version - shows current version
version:
	@echo "EndoscopeViewer Build System"
	@echo "Version: 1.0"
	@if [ -f "build/EndoscopeViewer.app/Contents/Info.plist" ]; then \
		echo "App Version: $$(defaults read $$(pwd)/build/EndoscopeViewer.app/Contents/Info.plist CFBundleShortVersionString)"; \
	fi
