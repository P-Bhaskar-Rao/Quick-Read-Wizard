#!/bin/bash

# Deployment script for Flask backend
set -e  # Exit on any error

echo "🚀 Starting deployment process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Please create one from .env.production template."
    echo "cp .env.production .env"
    echo "Then edit .env with your actual values."
    exit 1
fi

# Build the Docker image
print_status "Building Docker image..."
docker-compose build

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down

# Start the application
print_status "Starting the application..."
docker-compose up -d

# Wait for the application to start
print_status "Waiting for application to start..."
sleep 10

# Check if the application is running
if curl -f http://localhost:8000/api/status &> /dev/null; then
    print_status "✅ Application is running successfully!"
    print_status "Backend URL: http://localhost:8000"
    print_status "Health check: http://localhost:8000/api/status"
else
    print_error "❌ Application failed to start properly"
    print_status "Checking logs..."
    docker-compose logs
    exit 1
fi

# Show running containers
print_status "Running containers:"
docker-compose ps

echo ""
print_status "🎉 Deployment completed successfully!"
print_status "You can check logs with: docker-compose logs -f"
print_status "To stop the application: docker-compose down"