#!/usr/bin/env ruby

# Load our gem code directly
require_relative 'lib/rails_routes_to_collections'

# Mock Rails route structure based on what we saw in blink-backend
class MockRoute
  attr_accessor :name, :verb, :path, :defaults, :constraints

  def initialize(name, verb, path, controller, action, constraints = {})
    @name = name
    @verb = verb
    @path = MockPath.new(path)
    @defaults = { controller: controller, action: action }
    @constraints = constraints
  end

  def present?
    true
  end
end

class MockPath
  attr_accessor :spec

  def initialize(path)
    @spec = path
  end

  def to_s
    @spec
  end

  def present?
    true
  end
end

class MockRouteSet
  def routes
    [
      # API v3 routes from blink-backend
      MockRoute.new('api_v3_upload', 'POST', '/api/v3/upload', 'api/v3/uploaders', 'upload_image'),
      MockRoute.new('api_v3_upload_env', 'POST', '/api/v3/upload-env', 'api/v3/uploaders', 'upload_env'),
      MockRoute.new('api_v3_users', 'POST', '/api/v3/users', 'api/v3/single_sign_in', 'create'),
      MockRoute.new('api_v3_user', 'PATCH', '/api/v3/users/:single_sign_on_id', 'api/v3/single_sign_in', 'update'),
      MockRoute.new('api_v3_user_delete', 'DELETE', '/api/v3/users/:single_sign_on_id', 'api/v3/single_sign_in', 'destroy'),
      MockRoute.new('api_v3_gateway', 'POST', '/api/v3/gateway', 'api/v3/gateway', 'gatway'),
      MockRoute.new('api_v3_feature_flags', 'GET', '/api/v3/feature-flag-list', 'api/v3/feature_flags', 'feature_flag_list'),
      MockRoute.new('api_v3_categories', 'GET', '/api/v3/categories/categories', 'api/v3/categories', 'index'),
      MockRoute.new('api_v3_category', 'GET', '/api/v3/categories/categories/:category_id', 'api/v3/categories', 'show'),
      MockRoute.new('api_v3_category_update', 'PATCH', '/api/v3/categories/categories/:category_id', 'api/v3/categories', 'update'),
      MockRoute.new('api_v3_category_delete', 'DELETE', '/api/v3/categories/categories/:category_id', 'api/v3/categories', 'destroy'),
      
      # API v2 routes
      MockRoute.new('api_v2_hotel_sheet', 'GET', '/api/v2/hotel-sheet', 'api/v2/sheets', 'hotel_sheet'),
      MockRoute.new('api_v2_flights_sheet', 'GET', '/api/v2/flights-sheet', 'api/v2/sheets', 'get_flights_sheet'),
      
      # Root routes
      MockRoute.new('root', 'GET', '/', 'home', 'index'),
      MockRoute.new('document_endpoints', 'POST', '/document-enpoints', 'api_documentations', 'add_endpoint_to_swagger'),
      
      # Sample mounted engine routes (simplified)
      MockRoute.new('users_index', 'GET', '/users', 'users/users', 'index'),
      MockRoute.new('users_show', 'GET', '/users/:id', 'users/users', 'show'),
      MockRoute.new('users_create', 'POST', '/users', 'users/users', 'create'),
      MockRoute.new('users_update', 'PUT', '/users/:id', 'users/users', 'update'),
      MockRoute.new('users_delete', 'DELETE', '/users/:id', 'users/users', 'destroy'),
      
      # Sample accommodation routes
      MockRoute.new('accommodations_index', 'GET', '/accommodations', 'accommodation/accommodations', 'index'),
      MockRoute.new('accommodations_show', 'GET', '/accommodations/:id', 'accommodation/accommodations', 'show'),
      MockRoute.new('accommodations_create', 'POST', '/accommodations', 'accommodation/accommodations', 'create'),
      
      # Sample event management routes
      MockRoute.new('events_index', 'GET', '/events', 'event_management/events', 'index'),
      MockRoute.new('events_show', 'GET', '/events/:id', 'event_management/events', 'show'),
      MockRoute.new('events_create', 'POST', '/events', 'event_management/events', 'create'),
      MockRoute.new('events_update', 'PUT', '/events/:id', 'event_management/events', 'update'),
      
      # Sample transportation routes
      MockRoute.new('rides_index', 'GET', '/rides', 'transportation/rides', 'index'),
      MockRoute.new('rides_show', 'GET', '/rides/:id', 'transportation/rides', 'show'),
      MockRoute.new('rides_create', 'POST', '/rides', 'transportation/rides', 'create'),
    ]
  end
end

class MockRailsApp
  def routes
    MockRouteSet.new
  end
end

# Mock Rails class
class Rails
  def self.application
    MockRailsApp.new
  end
end

puts "🚀 Testing Rails Routes to Collections Gem with Blink Backend Mock Data"
puts "=" * 70

begin
  # Initialize the route extractor with our mock Rails app
  puts "📊 Extracting routes from mock Blink Backend application..."
  extractor = RailsRoutesToCollections::RouteExtractor.new(Rails.application)
  
  # Extract routes
  routes = extractor.extract_routes
  puts "✅ Found #{routes.length} valid routes"
  
  # Show some sample routes
  puts "\n📋 Sample Routes:"
  routes.first(10).each_with_index do |route, index|
    puts "  #{index + 1}. #{route[:verb]} #{route[:path]} -> #{route[:controller]}##{route[:action]}"
  end
  
  if routes.length > 10
    puts "  ... and #{routes.length - 10} more routes"
  end
  
  # Test route grouping
  puts "\n📁 Testing route grouping..."
  route_groups = extractor.extract_route_groups
  puts "✅ Organized into #{route_groups.length} controller groups:"
  
  route_groups.each do |group|
    puts "  - #{group[:name]}: #{group[:routes].length} routes"
  end
  
  # Test Postman generation
  puts "\n🔧 Testing Postman collection generation..."
  postman_generator = RailsRoutesToCollections::PostmanGenerator.new(extractor)
  postman_collection = postman_generator.generate('Blink Backend API', 'https://api.blink-app.com')
  
  puts "✅ Generated Postman collection:"
  puts "  - Collection name: #{postman_collection[:info][:name]}"
  puts "  - Schema version: #{postman_collection[:info][:schema]}"
  puts "  - Total folders: #{postman_collection[:item].length}"
  puts "  - Base URL variable: #{postman_collection[:variable].find { |v| v[:key] == 'base_url' }[:value]}"
  
  # Show folder structure
  puts "\n📁 Postman Collection Structure:"
  postman_collection[:item].each_with_index do |folder, index|
    puts "  #{index + 1}. #{folder[:name]} (#{folder[:item].length} requests)"
    folder[:item].first(3).each do |request|
      puts "     - #{request[:name]} (#{request[:request][:method]})"
    end
    if folder[:item].length > 3
      puts "     ... and #{folder[:item].length - 3} more requests"
    end
  end
  
  # Save Postman collection
  postman_filename = '/Users/ahmed/Blink/blink_backend_postman_collection.json'
  postman_generator.write_to_file(postman_filename, 'Blink Backend API', 'https://api.blink-app.com')
  puts "\n💾 Saved Postman collection to: #{postman_filename}"
  
  # Test Apidog generation
  puts "\n🔧 Testing Apidog collection generation..."
  apidog_generator = RailsRoutesToCollections::ApidogGenerator.new(extractor)
  apidog_collection = apidog_generator.generate('Blink Backend API', 'https://api.blink-app.com')
  
  puts "✅ Generated Apidog collection:"
  puts "  - Collection name: #{apidog_collection[:name]}"
  puts "  - Version: #{apidog_collection[:apidogVersion]}"
  puts "  - Total folders: #{apidog_collection[:folders].length}"
  puts "  - Total APIs: #{apidog_collection[:apis].length}"
  puts "  - Base URL variable: #{apidog_collection[:variables].find { |v| v[:key] == 'base_url' }[:value]}"
  
  # Show folder structure
  puts "\n📁 Apidog Collection Structure:"
  apidog_collection[:folders].each_with_index do |folder, index|
    folder_apis = apidog_collection[:apis].select { |api| api[:folderId] == folder[:id] }
    puts "  #{index + 1}. #{folder[:name]} (#{folder_apis.length} APIs)"
    folder_apis.first(3).each do |api|
      puts "     - #{api[:name]} (#{api[:method]})"
    end
    if folder_apis.length > 3
      puts "     ... and #{folder_apis.length - 3} more APIs"
    end
  end
  
  # Save Apidog collection
  apidog_filename = '/Users/ahmed/Blink/blink_backend_apidog_collection.json'
  apidog_generator.write_to_file(apidog_filename, 'Blink Backend API', 'https://api.blink-app.com')
  puts "\n💾 Saved Apidog collection to: #{apidog_filename}"
  
  puts "\n🎉 SUCCESS! Both collections have been generated successfully!"
  puts "\n📥 Import Instructions:"
  puts "  🟦 Postman: File > Import > #{postman_filename}"
  puts "  🟢 Apidog: Import > From File > #{apidog_filename}"
  
  # Show CLI usage
  puts "\n🔧 CLI Usage Examples:"
  puts "  # Generate Postman collection:"
  puts "  $ rails_routes_to_collections --format postman --name \"Blink API\" --base-url https://api.blink-app.com"
  puts ""
  puts "  # Generate Apidog collection:"
  puts "  $ rails_routes_to_collections --format apidog --name \"Blink API\" --base-url https://api.blink-app.com"
  puts ""
  puts "  # Using Rails rake tasks (when gem is installed):"
  puts "  $ rails routes:export:postman"
  puts "  $ rails routes:export:apidog"
  puts "  $ rails routes:export:all"
  
  # Show some sample request details
  puts "\n🔍 Sample Generated Request Details:"
  sample_request = postman_collection[:item].first[:item].first
  puts "Request Name: #{sample_request[:name]}"
  puts "Method: #{sample_request[:request][:method]}"
  puts "URL: #{sample_request[:request][:url][:raw]}"
  puts "Headers: #{sample_request[:request][:header].map { |h| "#{h[:key]}: #{h[:value]}" }.join(', ')}"
  
rescue => e
  puts "\n❌ ERROR: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.first(10).join("\n")
end