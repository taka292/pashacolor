#!/usr/bin/env bash
# exit on error
set -o errexit

echo "Starting Render build script..."

# Install dependencies
echo "Installing dependencies..."
bundle install

# Precompile assets
echo "Precompiling assets..."
bundle exec rails assets:precompile

# Clean up assets
echo "Cleaning up assets..."
bundle exec rails assets:clean

# Run database migrations
echo "Running database migrations..."
bundle exec rails db:migrate

# Load seed data (only on first deploy when no color themes exist)
echo "Checking if seed data needs to be loaded..."
if bundle exec rails runner "exit(ColorTheme.count == 0 ? 0 : 1)" 2>/dev/null; then
  echo "Loading seed data..."
  bundle exec rails db:seed
else
  echo "Seed data already exists, skipping..."
fi

echo "Build script completed successfully."

