# Makefile
.PHONY: build clean zip lint run dev-setup help verify

# Configuration
EXTENSION_NAME = stayactive
VERSION = $(shell grep '"version"' src/manifest.json | cut -d'"' -f4)
ZIP_NAME = $(EXTENSION_NAME)-$(VERSION).zip
BUILD_DIR = build
DIST_DIR = dist
SRC_DIR = src

# Source directories
JS_DIR = $(SRC_DIR)/js
CSS_DIR = $(SRC_DIR)/css
ICONS_DIR = $(SRC_DIR)/icons

# Build directories
BUILD_JS_DIR = $(BUILD_DIR)/js
BUILD_CSS_DIR = $(BUILD_DIR)/css
BUILD_ICONS_DIR = $(BUILD_DIR)/icons

# JavaScript files
JS_FILES = background.js \
           popup.js

# CSS files
CSS_FILES = styles.css

# HTML files
HTML_FILES = popup.html

# Icon files
ICON_FILES = icon48.png

# Create build directory and copy files
build: clean
	@echo "Building $(EXTENSION_NAME) v$(VERSION)..."

	# Create directory structure
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BUILD_JS_DIR)
	@mkdir -p $(BUILD_CSS_DIR)
	@mkdir -p $(BUILD_ICONS_DIR)

	# Copy manifest
	@cp $(SRC_DIR)/manifest.json $(BUILD_DIR)/

	# Copy HTML files
	@echo "Copying HTML files..."
	@for file in $(HTML_FILES); do \
		cp $(SRC_DIR)/$$file $(BUILD_DIR)/$$file; \
	done

	# Copy JavaScript files
	@echo "Copying JavaScript files..."
	@for file in $(JS_FILES); do \
		cp $(JS_DIR)/$$file $(BUILD_JS_DIR)/$$file; \
	done

	# Copy CSS files
	@echo "Copying CSS files..."
	@for file in $(CSS_FILES); do \
		cp $(CSS_DIR)/$$file $(BUILD_CSS_DIR)/$$file; \
	done

	# Copy icons
	@echo "Copying icons..."
	@for file in $(ICON_FILES); do \
		cp $(ICONS_DIR)/$$file $(BUILD_ICONS_DIR)/$$file; \
	done

	@echo "Build complete in $(BUILD_DIR)/"

# Create distribution package
zip: build
	@echo "Creating distribution package..."
	@mkdir -p $(DIST_DIR)
	@cd $(BUILD_DIR) && zip -r ../$(DIST_DIR)/$(ZIP_NAME) ./*
	@echo "Created: $(DIST_DIR)/$(ZIP_NAME)"
	@echo "Extension size: $$(du -h $(DIST_DIR)/$(ZIP_NAME) | cut -f1)"

# Clean build and dist directories
clean:
	@echo "Cleaning build directories..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DIST_DIR)
	@echo "Clean complete!"

# Verify the structure is correct
verify:
	@echo "Verifying project structure..."
	# Check directories
	@test -d $(JS_DIR) || (echo "Error: JavaScript directory missing" && exit 1)
	@test -d $(CSS_DIR) || (echo "Error: CSS directory missing" && exit 1)
	@test -d $(ICONS_DIR) || (echo "Error: Icons directory missing" && exit 1)

	# Check JavaScript files
	@for file in $(JS_FILES); do \
		if [ ! -f "$(JS_DIR)/$$file" ]; then \
			echo "Error: Missing $$file in js directory"; \
			exit 1; \
		fi \
	done

	# Check CSS files
	@for file in $(CSS_FILES); do \
		if [ ! -f "$(CSS_DIR)/$$file" ]; then \
			echo "Error: Missing $$file in css directory"; \
			exit 1; \
		fi \
	done

	# Check HTML files
	@for file in $(HTML_FILES); do \
		if [ ! -f "$(SRC_DIR)/$$file" ]; then \
			echo "Error: Missing $$file in src directory"; \
			exit 1; \
		fi \
	done

	# Check icons
	@for file in $(ICON_FILES); do \
		if [ ! -f "$(ICONS_DIR)/$$file" ]; then \
			echo "Error: Missing $$file in icons directory"; \
			exit 1; \
		fi \
	done

	# Check manifest
	@test -f $(SRC_DIR)/manifest.json || (echo "Error: manifest.json missing" && exit 1)

	@echo "All required files present!"

# Install development dependencies
dev-setup:
	@echo "Setting up development environment..."
	@which npm > /dev/null || (echo "Please install Node.js and npm first" && exit 1)
	@npm install --save-dev web-ext
	@echo "Setup complete!"

# Run extension in Firefox for testing
run:
	@echo "Running extension in Firefox..."
	@npx web-ext run --source-dir $(SRC_DIR)

# Lint the extension
lint:
	@echo "Linting extension..."
	@npx web-ext lint --source-dir $(SRC_DIR)

# Help command
help:
	@echo "StayActive Extension Build System"
	@echo ""
	@echo "Project Structure:"
	@echo "  src/               - Source files"
	@echo "    ├── js/         - JavaScript files"
	@echo "    ├── css/        - CSS files"
	@echo "    ├── icons/      - Icon files"
	@echo "    ├── manifest.json"
	@echo "    └── popup.html"
	@echo "  build/             - Build directory"
	@echo "  dist/              - Distribution packages"
	@echo ""
	@echo "Commands:"
	@echo "  make build     - Build the extension"
	@echo "  make zip      - Create distribution package"
	@echo "  make clean    - Clean build directories"
	@echo "  make verify   - Verify project structure"
	@echo "  make dev-setup- Install development dependencies"
	@echo "  make run      - Run extension in Firefox"
	@echo "  make lint     - Lint the extension"
	@echo "  make help     - Show this help message"

# Initialize project structure
init:
	@echo "Initializing project structure..."
	@mkdir -p $(JS_DIR)
	@mkdir -p $(CSS_DIR)
	@mkdir -p $(ICONS_DIR)
	@echo "Project structure created!"