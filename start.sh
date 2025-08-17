#!/bin/bash

# 🏛️ Nefer E-commerce Quick Start Script
# This script helps you get started with the Nefer project quickly

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

print_header() {
    echo -e "${PURPLE}"
    echo "🏛️ ======================================"
    echo "   NEFER E-COMMERCE QUICK START"
    echo "   نفِر - Beautiful Egyptian Marketplace"
    echo "======================================${NC}"
    echo ""
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_deps=()
    
    if ! command_exists flutter; then
        missing_deps+=("Flutter SDK")
    fi
    
    if ! command_exists dart; then
        missing_deps+=("Dart SDK")
    fi
    
    if ! command_exists firebase; then
        missing_deps+=("Firebase CLI")
    fi
    
    if ! command_exists git; then
        missing_deps+=("Git")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        echo "Please install the missing dependencies and try again."
        echo ""
        echo "Installation guides:"
        echo "  Flutter: https://docs.flutter.dev/get-started/install"
        echo "  Firebase CLI: https://firebase.google.com/docs/cli#install_the_firebase_cli"
        echo "  Git: https://git-scm.com/downloads"
        exit 1
    fi
    
    print_success "All prerequisites are installed!"
}

# Function to setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    # Create .env file if it doesn't exist
    if [ ! -f .env ]; then
        print_status "Creating .env file from template..."
        cp .env.example .env
        print_warning "Please edit .env file with your actual Firebase configuration"
        print_warning "You can find your Firebase config at: https://console.firebase.google.com/"
    fi
    
    print_success "Environment setup complete!"
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing Flutter dependencies..."
    flutter pub get
    
    print_status "Installing Dart functions dependencies..."
    if [ -d "functions" ]; then
        cd functions
        if command_exists dart; then
            dart pub get
        else
            print_warning "Dart not found, skipping functions dependencies"
        fi
        cd ..
    fi
    
    print_success "Dependencies installed!"
}

# Function to setup Firebase
setup_firebase() {
    print_status "Setting up Firebase..."
    
    if [ ! -f .firebaserc ]; then
        print_warning "Firebase project not configured."
        print_status "Please run 'firebase init' to setup your Firebase project"
        print_status "Or run 'firebase use --add' if you already have a project"
        return
    fi
    
    print_success "Firebase setup complete!"
}

# Function to build the project
build_project() {
    print_status "Building the project..."
    
    # Build Flutter web
    print_status "Building Flutter web app..."
    flutter build web --release --web-renderer html
    
    # Build Dart functions if Dart is available
    if command_exists dart && [ -d "functions" ]; then
        print_status "Building Dart functions..."
        cd functions
        dart compile exe bin/main.dart -o bin/server
        cd ..
    fi
    
    print_success "Project built successfully!"
}

# Function to start development server
start_development() {
    print_status "Starting development environment..."
    
    # Check if we should start functions
    if command_exists dart && [ -d "functions" ]; then
        print_status "Starting Dart functions in background..."
        cd functions
        dart run bin/main.dart &
        FUNCTIONS_PID=$!
        cd ..
        
        # Wait a moment for functions to start
        sleep 3
    fi
    
    print_status "Starting Flutter web development server..."
    print_success "🚀 Development environment is starting!"
    print_success "📱 Web app will be available at: http://localhost:3000"
    
    if [ ! -z "$FUNCTIONS_PID" ]; then
        print_success "⚡ Functions available at: http://localhost:8080"
    fi
    
    # Start Flutter web
    flutter run -d chrome --web-port 3000
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  setup     Setup the project (install dependencies, configure environment)"
    echo "  build     Build the project"
    echo "  dev       Start development environment"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup     # Setup the project for first time"
    echo "  $0 dev       # Start development server"
    echo "  $0 build     # Build the project for production"
}

# Main function
main() {
    print_header
    
    case "${1:-dev}" in
        "setup")
            check_prerequisites
            setup_environment
            install_dependencies
            setup_firebase
            print_success "🎉 Setup complete! You can now run '$0 dev' to start development"
            ;;
        "build")
            check_prerequisites
            build_project
            ;;
        "dev")
            check_prerequisites
            if [ ! -f .env ]; then
                print_warning "Environment not configured. Running setup first..."
                setup_environment
                install_dependencies
            fi
            start_development
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Cleanup function
cleanup() {
    if [ ! -z "$FUNCTIONS_PID" ]; then
        print_status "Stopping functions server..."
        kill $FUNCTIONS_PID 2>/dev/null || true
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main "$@"
