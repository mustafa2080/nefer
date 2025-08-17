# 🏛️ Nefer E-commerce App Makefile
# Automation scripts for development, testing, and deployment

.PHONY: help setup clean build test analyze format generate deploy

# Default target
.DEFAULT_GOAL := help

# Colors for output
YELLOW := \033[1;33m
GREEN := \033[0;32m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Project info
PROJECT_NAME := nefer
FLUTTER_VERSION := 3.16.0
DART_VERSION := 3.2.0

## Help
help: ## Show this help message
	@echo "$(YELLOW)🏛️  Nefer E-commerce App - Development Commands$(NC)"
	@echo ""
	@echo "$(BLUE)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""

## Setup and Installation
setup: ## Setup the development environment
	@echo "$(YELLOW)🔧 Setting up development environment...$(NC)"
	@flutter --version
	@flutter doctor
	@flutter pub get
	@make generate
	@echo "$(GREEN)✅ Setup completed!$(NC)"

install: ## Install dependencies
	@echo "$(YELLOW)📦 Installing dependencies...$(NC)"
	@flutter pub get
	@cd functions && npm install
	@echo "$(GREEN)✅ Dependencies installed!$(NC)"

## Code Generation
generate: ## Generate code (models, routes, etc.)
	@echo "$(YELLOW)🔄 Generating code...$(NC)"
	@flutter packages pub run build_runner build --delete-conflicting-outputs
	@flutter gen-l10n
	@echo "$(GREEN)✅ Code generation completed!$(NC)"

generate-watch: ## Watch for changes and generate code
	@echo "$(YELLOW)👀 Watching for changes...$(NC)"
	@flutter packages pub run build_runner watch --delete-conflicting-outputs

## Development
dev: ## Run the app in development mode
	@echo "$(YELLOW)🚀 Starting development server...$(NC)"
	@flutter run --flavor dev --dart-define=ENVIRONMENT=development

dev-web: ## Run web version for admin dashboard
	@echo "$(YELLOW)🌐 Starting web development server...$(NC)"
	@flutter run -d chrome --web-port 8080 --dart-define=ENVIRONMENT=development

hot-reload: ## Run with hot reload enabled
	@echo "$(YELLOW)🔥 Starting with hot reload...$(NC)"
	@flutter run --hot --flavor dev

## Testing
test: ## Run all tests
	@echo "$(YELLOW)🧪 Running tests...$(NC)"
	@flutter test
	@echo "$(GREEN)✅ Tests completed!$(NC)"

test-coverage: ## Run tests with coverage
	@echo "$(YELLOW)📊 Running tests with coverage...$(NC)"
	@flutter test --coverage
	@genhtml coverage/lcov.info -o coverage/html
	@echo "$(GREEN)✅ Coverage report generated in coverage/html/$(NC)"

test-integration: ## Run integration tests
	@echo "$(YELLOW)🔗 Running integration tests...$(NC)"
	@flutter test integration_test/
	@echo "$(GREEN)✅ Integration tests completed!$(NC)"

test-unit: ## Run unit tests only
	@echo "$(YELLOW)🔬 Running unit tests...$(NC)"
	@flutter test test/unit/
	@echo "$(GREEN)✅ Unit tests completed!$(NC)"

test-widget: ## Run widget tests only
	@echo "$(YELLOW)🎨 Running widget tests...$(NC)"
	@flutter test test/widget/
	@echo "$(GREEN)✅ Widget tests completed!$(NC)"

## Code Quality
analyze: ## Analyze code for issues
	@echo "$(YELLOW)🔍 Analyzing code...$(NC)"
	@flutter analyze
	@echo "$(GREEN)✅ Code analysis completed!$(NC)"

format: ## Format code
	@echo "$(YELLOW)✨ Formatting code...$(NC)"
	@dart format lib/ test/ integration_test/
	@echo "$(GREEN)✅ Code formatted!$(NC)"

lint: ## Run linter
	@echo "$(YELLOW)🧹 Running linter...$(NC)"
	@flutter analyze --fatal-infos
	@echo "$(GREEN)✅ Linting completed!$(NC)"

fix: ## Fix auto-fixable issues
	@echo "$(YELLOW)🔧 Fixing issues...$(NC)"
	@dart fix --apply
	@make format
	@echo "$(GREEN)✅ Issues fixed!$(NC)"

## Building
build-android: ## Build Android APK
	@echo "$(YELLOW)🤖 Building Android APK...$(NC)"
	@flutter build apk --release --flavor prod
	@echo "$(GREEN)✅ Android APK built!$(NC)"

build-android-bundle: ## Build Android App Bundle
	@echo "$(YELLOW)📦 Building Android App Bundle...$(NC)"
	@flutter build appbundle --release --flavor prod
	@echo "$(GREEN)✅ Android App Bundle built!$(NC)"

build-ios: ## Build iOS app
	@echo "$(YELLOW)🍎 Building iOS app...$(NC)"
	@flutter build ios --release --flavor prod
	@echo "$(GREEN)✅ iOS app built!$(NC)"

build-web: ## Build web app
	@echo "$(YELLOW)🌐 Building web app...$(NC)"
	@flutter build web --release --dart-define=ENVIRONMENT=production
	@echo "$(GREEN)✅ Web app built!$(NC)"

build-all: ## Build for all platforms
	@echo "$(YELLOW)🏗️  Building for all platforms...$(NC)"
	@make build-android
	@make build-ios
	@make build-web
	@echo "$(GREEN)✅ All builds completed!$(NC)"

## Cleaning
clean: ## Clean build files
	@echo "$(YELLOW)🧹 Cleaning build files...$(NC)"
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/
	@echo "$(GREEN)✅ Cleaned!$(NC)"

clean-all: ## Deep clean (including dependencies)
	@echo "$(YELLOW)🧹 Deep cleaning...$(NC)"
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/
	@rm -rf pubspec.lock
	@rm -rf ios/Pods/
	@rm -rf ios/Podfile.lock
	@rm -rf android/.gradle/
	@rm -rf functions/node_modules/
	@echo "$(GREEN)✅ Deep cleaned!$(NC)"

reset: ## Reset project (clean + install)
	@echo "$(YELLOW)🔄 Resetting project...$(NC)"
	@make clean-all
	@make install
	@make generate
	@echo "$(GREEN)✅ Project reset!$(NC)"

## Firebase
firebase-login: ## Login to Firebase
	@echo "$(YELLOW)🔥 Logging into Firebase...$(NC)"
	@firebase login

firebase-deploy: ## Deploy to Firebase
	@echo "$(YELLOW)🚀 Deploying to Firebase...$(NC)"
	@firebase deploy
	@echo "$(GREEN)✅ Deployed to Firebase!$(NC)"

firebase-deploy-functions: ## Deploy Cloud Functions only
	@echo "$(YELLOW)⚡ Deploying Cloud Functions...$(NC)"
	@firebase deploy --only functions
	@echo "$(GREEN)✅ Cloud Functions deployed!$(NC)"

firebase-deploy-hosting: ## Deploy hosting only
	@echo "$(YELLOW)🌐 Deploying hosting...$(NC)"
	@firebase deploy --only hosting
	@echo "$(GREEN)✅ Hosting deployed!$(NC)"

firebase-deploy-database: ## Deploy database rules
	@echo "$(YELLOW)🗄️  Deploying database rules...$(NC)"
	@firebase deploy --only database
	@echo "$(GREEN)✅ Database rules deployed!$(NC)"

## Development Tools
doctor: ## Run Flutter doctor
	@echo "$(YELLOW)👨‍⚕️ Running Flutter doctor...$(NC)"
	@flutter doctor -v

devices: ## List connected devices
	@echo "$(YELLOW)📱 Connected devices:$(NC)"
	@flutter devices

emulators: ## List available emulators
	@echo "$(YELLOW)📱 Available emulators:$(NC)"
	@flutter emulators

logs: ## Show app logs
	@echo "$(YELLOW)📋 Showing logs...$(NC)"
	@flutter logs

## Localization
l10n-extract: ## Extract strings for localization
	@echo "$(YELLOW)🌍 Extracting strings...$(NC)"
	@flutter gen-l10n
	@echo "$(GREEN)✅ Strings extracted!$(NC)"

## Performance
profile: ## Run in profile mode
	@echo "$(YELLOW)📊 Running in profile mode...$(NC)"
	@flutter run --profile --flavor dev

trace: ## Run with tracing
	@echo "$(YELLOW)🔍 Running with tracing...$(NC)"
	@flutter run --trace-startup --profile --flavor dev

## Deployment
deploy-staging: ## Deploy to staging
	@echo "$(YELLOW)🚀 Deploying to staging...$(NC)"
	@firebase use staging
	@make build-web
	@firebase deploy --only hosting
	@echo "$(GREEN)✅ Deployed to staging!$(NC)"

deploy-production: ## Deploy to production
	@echo "$(YELLOW)🚀 Deploying to production...$(NC)"
	@firebase use production
	@make build-web
	@firebase deploy
	@echo "$(GREEN)✅ Deployed to production!$(NC)"

## Utilities
version: ## Show version info
	@echo "$(YELLOW)📋 Version Information:$(NC)"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Flutter: $(FLUTTER_VERSION)"
	@echo "Dart: $(DART_VERSION)"
	@flutter --version
	@dart --version

size-analysis: ## Analyze app size
	@echo "$(YELLOW)📏 Analyzing app size...$(NC)"
	@flutter build apk --analyze-size --flavor prod

performance-test: ## Run performance tests
	@echo "$(YELLOW)⚡ Running performance tests...$(NC)"
	@flutter drive --target=test_driver/perf_test.dart

## Git Hooks
install-hooks: ## Install git hooks
	@echo "$(YELLOW)🪝 Installing git hooks...$(NC)"
	@cp scripts/pre-commit .git/hooks/
	@chmod +x .git/hooks/pre-commit
	@echo "$(GREEN)✅ Git hooks installed!$(NC)"

## Documentation
docs: ## Generate documentation
	@echo "$(YELLOW)📚 Generating documentation...$(NC)"
	@dart doc
	@echo "$(GREEN)✅ Documentation generated!$(NC)"

## Quick Commands
quick-test: format analyze test ## Quick test (format + analyze + test)

quick-build: clean generate build-android ## Quick build for Android

ci: install generate analyze test build-android ## CI pipeline

## Project Status
status: ## Show project status
	@echo "$(YELLOW)📊 Project Status:$(NC)"
	@echo ""
	@echo "$(BLUE)Flutter Doctor:$(NC)"
	@flutter doctor
	@echo ""
	@echo "$(BLUE)Dependencies:$(NC)"
	@flutter pub deps
	@echo ""
	@echo "$(BLUE)Git Status:$(NC)"
	@git status --short
