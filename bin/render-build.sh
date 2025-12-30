#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Precompile assets
bundle exec rails assets:precompile

# Clean up assets
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Load seed data (optional - comment out if not needed)
# bundle exec rails db:seed


