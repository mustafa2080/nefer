#!/bin/bash

# 🏛️ Nefer Functions Runner Script
# Quick script to run Dart Cloud Functions locally

echo "🏛️ Starting Nefer Cloud Functions..."

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart is not installed. Please install Dart SDK first."
    echo "Visit: https://dart.dev/get-dart"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
dart pub get

# Run the server
echo "🚀 Starting server on port 8080..."
dart run bin/main.dart

echo "✅ Server started successfully!"
echo "🌐 API available at: http://localhost:8080"
echo "📋 Health check: http://localhost:8080/health"
echo "ℹ️  API info: http://localhost:8080/info"
