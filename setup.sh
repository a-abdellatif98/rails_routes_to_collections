#!/bin/bash

# Rails Routes to Collections - Quick Setup Script
# Usage: ./setup.sh /path/to/rails/project

set -e

GEM_NAME="rails_routes_to_collections"
GEM_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "🚀 Rails Routes to Collections - Quick Setup"
echo "============================================"

# Check if target is a Rails project
if [[ ! -f "$TARGET_DIR/config/application.rb" || ! -f "$TARGET_DIR/Gemfile" ]]; then
    echo "❌ Error: Not a Rails project directory"
    echo "Usage: ./setup.sh /path/to/rails/project"
    exit 1
fi

echo "📁 Target Rails project: $TARGET_DIR"

# Create local_gems directory
LOCAL_GEMS_DIR="$TARGET_DIR/local_gems"
mkdir -p "$LOCAL_GEMS_DIR"
echo "✅ Created local_gems directory"

# Copy gem
GEM_TARGET_PATH="$LOCAL_GEMS_DIR/$GEM_NAME"
if [[ -d "$GEM_TARGET_PATH" ]]; then
    echo "📦 Gem directory exists, removing old version..."
    rm -rf "$GEM_TARGET_PATH"
fi

cp -r "$GEM_SOURCE_DIR" "$GEM_TARGET_PATH"
echo "✅ Copied gem to $GEM_TARGET_PATH"

# Update Gemfile if needed
GEMFILE="$TARGET_DIR/Gemfile"
GEM_LINE="gem '$GEM_NAME', path: './local_gems/$GEM_NAME'"

if ! grep -q "$GEM_NAME" "$GEMFILE"; then
    echo "" >> "$GEMFILE"
    echo "# Rails Routes to Collections Gem" >> "$GEMFILE"
    echo "$GEM_LINE" >> "$GEMFILE"
    echo "✅ Added gem to Gemfile"
else
    echo "✅ Gem already in Gemfile"
fi

# Create CLI wrapper script
CLI_SCRIPT="$TARGET_DIR/generate_collections"
cat > "$CLI_SCRIPT" << 'EOF'
#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails Routes to Collections CLI
require_relative 'config/environment'
$LOAD_PATH.unshift File.expand_path('./local_gems/rails_routes_to_collections/lib', __dir__)
require 'rails_routes_to_collections'

RailsRoutesToCollections::CLI.run(ARGV)
EOF

chmod +x "$CLI_SCRIPT"
echo "✅ Created CLI script: ./generate_collections"

# Create quick generator script
QUICK_SCRIPT="$TARGET_DIR/generate_api_collections.rb"
cat > "$QUICK_SCRIPT" << 'EOF'
#!/usr/bin/env ruby
# frozen_string_literal: true

# Quick API Collections Generator
require_relative 'config/environment'
$LOAD_PATH.unshift File.expand_path('./local_gems/rails_routes_to_collections/lib', __dir__)
require 'rails_routes_to_collections'

puts '🚀 Generating API Collections...'

extractor = RailsRoutesToCollections::RouteExtractor.new
routes = extractor.extract_routes
puts "📊 Found #{routes.length} routes"

# Generate Postman collection
postman_gen = RailsRoutesToCollections::PostmanGenerator.new(extractor)
postman_gen.write_to_file('postman_collection.json', 'My API', 'http://localhost:3000')
puts '✅ Generated: postman_collection.json'

# Generate Apidog collection
apidog_gen = RailsRoutesToCollections::ApidogGenerator.new(extractor)
apidog_gen.write_to_file('apidog_collection.json', 'My API', 'http://localhost:3000')
puts '✅ Generated: apidog_collection.json'

puts '🎉 Done! Import these files into Postman or Apidog.'
EOF

chmod +x "$QUICK_SCRIPT"
echo "✅ Created quick script: ./generate_api_collections.rb"

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Run: bundle install"
echo "2. Generate collections:"
echo "   • ./generate_collections --format postman"
echo "   • ./generate_collections --format apidog"
echo "   • bundle exec rails routes:export:postman"
echo "   • ruby generate_api_collections.rb"
echo ""
echo "📖 Usage Examples:"
echo "   ./generate_collections --format apidog --name \"My API\" --base-url https://api.myapp.com"
echo "   bundle exec rails routes:export:all"