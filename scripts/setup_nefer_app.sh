#!/bin/bash

# 🏛️ Nefer E-commerce App Setup Script
# This script automates the setup process for the Nefer application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Pharaonic-themed banner
print_banner() {
    echo -e "${YELLOW}"
    echo "🏛️ ═══════════════════════════════════════════════════════════════"
    echo "   ███╗   ██╗███████╗███████╗███████╗██████╗ "
    echo "   ████╗  ██║██╔════╝██╔════╝██╔════╝██╔══██╗"
    echo "   ██╔██╗ ██║█████╗  █████╗  █████╗  ██████╔╝"
    echo "   ██║╚██╗██║██╔══╝  ██╔══╝  ██╔══╝  ██╔══██╗"
    echo "   ██║ ╚████║███████╗██║     ███████╗██║  ██║"
    echo "   ╚═╝  ╚═══╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝"
    echo ""
    echo "   🏺 Marketplace of the Pharaohs 🏺"
    echo "   Automated Setup Script v1.0"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check Flutter
    if ! command_exists flutter; then
        missing_tools+=("Flutter SDK")
    else
        log_success "Flutter SDK found"
    fi
    
    # Check Dart
    if ! command_exists dart; then
        missing_tools+=("Dart SDK")
    else
        log_success "Dart SDK found"
    fi
    
    # Check Firebase CLI
    if ! command_exists firebase; then
        missing_tools+=("Firebase CLI")
    else
        log_success "Firebase CLI found"
    fi
    
    # Check Node.js
    if ! command_exists node; then
        missing_tools+=("Node.js")
    else
        log_success "Node.js found"
    fi
    
    # Check Git
    if ! command_exists git; then
        missing_tools+=("Git")
    else
        log_success "Git found"
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo "Please install the missing tools and run this script again."
        echo "Visit: https://docs.nefer-ecommerce.com/setup for installation guides"
        exit 1
    fi
    
    log_success "All prerequisites satisfied!"
}

# Setup Flutter dependencies
setup_flutter() {
    log_step "Setting up Flutter dependencies..."
    
    # Clean previous builds
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Generate code
    log_info "Generating code files..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    # Generate localization
    log_info "Generating localization files..."
    flutter gen-l10n
    
    log_success "Flutter setup completed!"
}

# Setup Firebase
setup_firebase() {
    log_step "Setting up Firebase..."
    
    # Check if user is logged in
    if ! firebase projects:list >/dev/null 2>&1; then
        log_warning "Not logged into Firebase. Please login:"
        firebase login
    fi
    
    # Initialize Firebase project
    if [ ! -f "firebase.json" ]; then
        log_info "Initializing Firebase project..."
        firebase init
    else
        log_info "Firebase already initialized"
    fi
    
    # Deploy security rules
    if [ -f "firebase_security_rules.json" ]; then
        log_info "Deploying database security rules..."
        firebase deploy --only database
    fi
    
    # Deploy Cloud Functions
    if [ -d "functions" ]; then
        log_info "Installing Cloud Functions dependencies..."
        cd functions
        npm install
        cd ..
        
        log_info "Deploying Cloud Functions..."
        firebase deploy --only functions
    fi
    
    log_success "Firebase setup completed!"
}

# Setup environment files
setup_environment() {
    log_step "Setting up environment configuration..."
    
    # Create .env files if they don't exist
    if [ ! -f ".env.dev" ]; then
        log_info "Creating development environment file..."
        cat > .env.dev << EOF
# Development Environment Configuration
ENVIRONMENT=development
DEBUG=true

# Firebase Configuration
FIREBASE_PROJECT_ID=nefer-ecommerce-dev
FIREBASE_API_KEY=your-dev-api-key
FIREBASE_AUTH_DOMAIN=nefer-ecommerce-dev.firebaseapp.com
FIREBASE_DATABASE_URL=https://nefer-ecommerce-dev-default-rtdb.firebaseio.com
FIREBASE_STORAGE_BUCKET=nefer-ecommerce-dev.appspot.com

# Payment Configuration (Test Keys)
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# API Configuration
API_BASE_URL=https://api-dev.nefer-ecommerce.com
API_VERSION=v1

# Feature Flags
ENABLE_FLASH_SALES=true
ENABLE_CHATBOT=true
ENABLE_ANALYTICS=true
ENABLE_DEBUG_TOOLS=true
EOF
        log_success "Created .env.dev file"
    fi
    
    if [ ! -f ".env.prod" ]; then
        log_info "Creating production environment file..."
        cat > .env.prod << EOF
# Production Environment Configuration
ENVIRONMENT=production
DEBUG=false

# Firebase Configuration
FIREBASE_PROJECT_ID=nefer-ecommerce
FIREBASE_API_KEY=your-prod-api-key
FIREBASE_AUTH_DOMAIN=nefer-ecommerce.firebaseapp.com
FIREBASE_DATABASE_URL=https://nefer-ecommerce-default-rtdb.firebaseio.com
FIREBASE_STORAGE_BUCKET=nefer-ecommerce.appspot.com

# Payment Configuration (Live Keys)
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...

# API Configuration
API_BASE_URL=https://api.nefer-ecommerce.com
API_VERSION=v1

# Feature Flags
ENABLE_FLASH_SALES=true
ENABLE_CHATBOT=true
ENABLE_ANALYTICS=true
ENABLE_DEBUG_TOOLS=false
EOF
        log_success "Created .env.prod file"
    fi
    
    log_warning "Please update the environment files with your actual configuration values"
}

# Setup admin users
setup_admin_users() {
    log_step "Setting up admin users..."
    
    if [ -f "scripts/setup_admin_users.js" ]; then
        log_info "Running admin user setup script..."
        node scripts/setup_admin_users.js
        log_success "Admin users setup completed!"
    else
        log_warning "Admin setup script not found. Please create admin users manually."
    fi
}

# Setup sample data
setup_sample_data() {
    log_step "Setting up sample data..."
    
    read -p "Do you want to import sample data? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "scripts/import_sample_data.js" ]; then
            log_info "Importing sample data..."
            node scripts/import_sample_data.js
            log_success "Sample data imported!"
        else
            log_warning "Sample data script not found"
        fi
    else
        log_info "Skipping sample data import"
    fi
}

# Verify installation
verify_installation() {
    log_step "Verifying installation..."
    
    # Check Flutter doctor
    log_info "Running Flutter doctor..."
    flutter doctor
    
    # Test build
    log_info "Testing debug build..."
    flutter build apk --debug --flavor dev
    
    if [ $? -eq 0 ]; then
        log_success "Debug build successful!"
    else
        log_error "Debug build failed. Please check the errors above."
        exit 1
    fi
    
    log_success "Installation verification completed!"
}

# Main setup function
main() {
    print_banner
    
    log_info "Starting Nefer e-commerce app setup..."
    echo ""
    
    # Run setup steps
    check_prerequisites
    echo ""
    
    setup_flutter
    echo ""
    
    setup_firebase
    echo ""
    
    setup_environment
    echo ""
    
    setup_admin_users
    echo ""
    
    setup_sample_data
    echo ""
    
    verify_installation
    echo ""
    
    # Final success message
    echo -e "${GREEN}"
    echo "🎉 ═══════════════════════════════════════════════════════════════"
    echo "   Setup completed successfully!"
    echo "   Your Nefer e-commerce app is ready to run!"
    echo ""
    echo "   Next steps:"
    echo "   1. Update environment files with your configuration"
    echo "   2. Run: flutter run --flavor dev"
    echo "   3. Access admin dashboard at: http://localhost:8080/admin"
    echo "   4. Visit documentation: https://docs.nefer-ecommerce.com"
    echo ""
    echo "   🏺 Welcome to the Marketplace of the Pharaohs! 🏺"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${NC}"
}

# Run main function
main "$@"
