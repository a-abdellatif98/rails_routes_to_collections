# Rails Routes to Collections - Setup Guide

This guide provides multiple ways to set up the `rails_routes_to_collections` gem in any Rails project.

## 🚀 Quick Setup (Recommended)

### Option 1: Using the Setup Script

From the gem directory, run:

```bash
# Setup in current Rails project
./setup.sh

# Setup in specific Rails project
./setup.sh /path/to/your/rails/project
```

### Option 2: Using the Ruby Installer

```bash
# From the gem directory
ruby install.rb /path/to/your/rails/project
```

## 🔧 Manual Setup

### Step 1: Copy the Gem

```bash
# Create local_gems directory in your Rails project
mkdir -p /path/to/your/rails/project/local_gems

# Copy the gem
cp -r /path/to/rails-routes-to-collections /path/to/your/rails/project/local_gems/
```

### Step 2: Add to Gemfile

Add this line to your Rails project's Gemfile:

```ruby
gem 'rails_routes_to_collections', path: './local_gems/rails_routes_to_collections'
```

### Step 3: Install

```bash
bundle install
```

### Step 4: Create Convenience Scripts (Optional)

Create `generate_collections` executable:

```bash
#!/usr/bin/env ruby
require_relative 'config/environment'
$LOAD_PATH.unshift File.expand_path('./local_gems/rails_routes_to_collections/lib', __dir__)
require 'rails_routes_to_collections'

RailsRoutesToCollections::CLI.run(ARGV)
```

Make it executable:
```bash
chmod +x generate_collections
```

## 📋 Usage After Setup

### Command Line Interface

```bash
# Using bundler (always works)
bundle exec rails routes:export:postman
bundle exec rails routes:export:apidog
bundle exec rails routes:export:all

# Using convenience script (if created)
./generate_collections --format postman
./generate_collections --format apidog --name "My API" --base-url https://api.myapp.com

# Using Rails runner
bundle exec rails runner "
  extractor = RailsRoutesToCollections::RouteExtractor.new
  generator = RailsRoutesToCollections::PostmanGenerator.new(extractor)
  generator.write_to_file('collection.json', 'My API', 'https://api.myapp.com')
"
```

### Programmatic Usage

In Rails console or scripts:

```ruby
require 'rails_routes_to_collections'

# Initialize
extractor = RailsRoutesToCollections::RouteExtractor.new
postman_gen = RailsRoutesToCollections::PostmanGenerator.new(extractor)
apidog_gen = RailsRoutesToCollections::ApidogGenerator.new(extractor)

# Generate collections
postman_gen.write_to_file('postman.json', 'My API', 'https://api.myapp.com')
apidog_gen.write_to_file('apidog.json', 'My API', 'https://api.myapp.com')

# Get as JSON string
postman_json = postman_gen.generate_json('My API', 'https://api.myapp.com')
```

## 🔍 Troubleshooting

### Ruby Version Issues

If you encounter Ruby version conflicts:

1. Use the programmatic approach within Rails console
2. Create a standalone script that loads Rails environment manually
3. Ensure your project's Ruby version matches your system Ruby

### Rails Environment Issues

If Rails doesn't load properly:

1. Make sure you're in the Rails project root directory
2. Ensure `config/environment.rb` exists
3. Try loading Rails manually:

```ruby
require_relative 'config/environment'
```

### Bundle Issues

If bundler has conflicts:

1. Use `bundle exec` prefix for all commands
2. Check that the gem is properly added to Gemfile
3. Run `bundle install` after adding the gem

## 🎯 Features Available

After setup, you get:

- ✅ CLI tool for generating collections
- ✅ Rails rake tasks integration
- ✅ Programmatic Ruby API
- ✅ Postman v2.1.0 format support
- ✅ Apidog native format support
- ✅ Automatic route grouping by controller
- ✅ Path parameter detection with examples
- ✅ Environment variable setup
- ✅ Rich metadata and descriptions

## 📊 Example Output

The generated collections include:

- Organized folders by controller
- HTTP methods and URLs
- Path parameters with example values
- Request/response body templates
- Proper headers (Content-Type, Accept)
- Environment variables
- Rich descriptions with route metadata

## 🆘 Getting Help

If you encounter issues:

1. Check that you're in a Rails project directory
2. Verify Rails environment loads properly
3. Use `--verbose` flag for detailed output
4. Check the gem's README.md for more examples

## 🔄 Updating the Gem

To update to a newer version:

1. Replace the gem directory with the new version
2. Run `bundle install`
3. Restart any running Rails processes

That's it! The gem should now work seamlessly in your Rails project. 🎉