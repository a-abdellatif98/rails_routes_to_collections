# frozen_string_literal: true

namespace :routes do
  namespace :export do
    desc 'Generate Postman collection from Rails routes'
    task :postman, [:filename, :collection_name, :base_url] => :environment do |task, args|
      require 'rails_routes_to_collections'
      
      filename = args[:filename] || 'rails_routes_postman_collection.json'
      collection_name = args[:collection_name] || 'Rails API Routes'
      base_url = args[:base_url] || 'http://localhost:3000'
      
      extractor = RailsRoutesToCollections::RouteExtractor.new
      generator = RailsRoutesToCollections::PostmanGenerator.new(extractor)
      
      routes = extractor.extract_routes
      puts "Extracting #{routes.length} routes..."
      
      generator.write_to_file(filename, collection_name, base_url)
      
      puts "✅ Postman collection saved to: #{filename}"
      puts "📊 Collection contains #{routes.length} routes"
    end

    desc 'Generate Apidog collection from Rails routes'
    task :apidog, [:filename, :collection_name, :base_url] => :environment do |task, args|
      require 'rails_routes_to_collections'
      
      filename = args[:filename] || 'rails_routes_apidog_collection.json'
      collection_name = args[:collection_name] || 'Rails API Routes'
      base_url = args[:base_url] || 'http://localhost:3000'
      
      extractor = RailsRoutesToCollections::RouteExtractor.new
      generator = RailsRoutesToCollections::ApidogGenerator.new(extractor)
      
      routes = extractor.extract_routes
      puts "Extracting #{routes.length} routes..."
      
      generator.write_to_file(filename, collection_name, base_url)
      
      puts "✅ Apidog collection saved to: #{filename}"
      puts "📊 Collection contains #{routes.length} routes"
    end

    desc 'Generate both Postman and Apidog collections from Rails routes'
    task :all, [:postman_filename, :apidog_filename, :collection_name, :base_url] => :environment do |task, args|
      require 'rails_routes_to_collections'
      
      postman_filename = args[:postman_filename] || 'rails_routes_postman_collection.json'
      apidog_filename = args[:apidog_filename] || 'rails_routes_apidog_collection.json'
      collection_name = args[:collection_name] || 'Rails API Routes'
      base_url = args[:base_url] || 'http://localhost:3000'
      
      extractor = RailsRoutesToCollections::RouteExtractor.new
      
      routes = extractor.extract_routes
      puts "Extracting #{routes.length} routes..."
      
      # Generate Postman collection
      postman_generator = RailsRoutesToCollections::PostmanGenerator.new(extractor)
      postman_generator.write_to_file(postman_filename, collection_name, base_url)
      puts "✅ Postman collection saved to: #{postman_filename}"
      
      # Generate Apidog collection
      apidog_generator = RailsRoutesToCollections::ApidogGenerator.new(extractor)
      apidog_generator.write_to_file(apidog_filename, collection_name, base_url)
      puts "✅ Apidog collection saved to: #{apidog_filename}"
      
      puts "📊 Both collections contain #{routes.length} routes"
    end
  end
end