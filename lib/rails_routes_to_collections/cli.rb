# frozen_string_literal: true

require 'optparse'

module RailsRoutesToCollections
  class CLI
    def self.run(args)
      new(args).run
    end

    def initialize(args)
      @args = args
      @options = {
        format: 'postman',
        output: nil,
        name: 'Rails API Routes',
        base_url: 'http://localhost:3000'
      }
    end

    def run
      parse_options
      load_rails_environment
      generate_collection
    rescue RailsRoutesToCollections::Error => e
      puts "Error: #{e.message}"
      puts "\nMake sure you're running this command from a Rails application directory."
      exit 1
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts "Backtrace:"
      puts e.backtrace.first(5).join("\n") if @options[:verbose]
      exit 1
    end

    private

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: rails_routes_to_collections [options]"

        opts.on("-f", "--format FORMAT", "Output format: postman, apidog (default: postman)") do |format|
          unless %w[postman apidog].include?(format.downcase)
            puts "Error: Invalid format. Supported formats: postman, apidog"
            exit 1
          end
          @options[:format] = format.downcase
        end

        opts.on("-o", "--output FILE", "Output file path (default: routes_collection.json)") do |output|
          @options[:output] = output
        end

        opts.on("-n", "--name NAME", "Collection name (default: 'Rails API Routes')") do |name|
          @options[:name] = name
        end

        opts.on("-u", "--base-url URL", "Base URL for the API (default: 'http://localhost:3000')") do |url|
          @options[:base_url] = url
        end

        opts.on("-h", "--help", "Show this help message") do
          puts opts
          exit
        end

        opts.on("-v", "--version", "Show version") do
          puts RailsRoutesToCollections::VERSION
          exit
        end

        opts.on("--verbose", "Show verbose output") do
          @options[:verbose] = true
        end
      end.parse!(@args)
    end

    def load_rails_environment
      return if defined?(Rails) && Rails.application

      # Try to load Rails environment
      rails_env_files = ['config/environment.rb', './config/environment.rb']
      rails_env_file = rails_env_files.find { |file| File.exist?(file) }

      if rails_env_file
        puts "Loading Rails environment..." if @options[:verbose]
        require File.expand_path(rails_env_file)
      else
        raise RailsRoutesToCollections::Error, "Rails application not detected. Could not find config/environment.rb"
      end

      unless defined?(Rails) && Rails.application
        raise RailsRoutesToCollections::Error, "Rails application failed to load properly."
      end
    end

    def generate_collection
      extractor = RouteExtractor.new
      
      case @options[:format]
      when 'postman'
        generator = PostmanGenerator.new(extractor)
        default_filename = 'rails_routes_postman_collection.json'
      when 'apidog'
        generator = ApidogGenerator.new(extractor)
        default_filename = 'rails_routes_apidog_collection.json'
      end

      output_file = @options[:output] || default_filename
      
      puts "Extracting routes from Rails application..."
      routes = extractor.extract_routes
      puts "Found #{routes.length} valid routes"

      puts "Generating #{@options[:format].capitalize} collection..."
      generator.write_to_file(output_file, @options[:name], @options[:base_url])
      
      puts "✅ Collection saved to: #{output_file}"
      puts "📊 Collection stats:"
      puts "   - Format: #{@options[:format].capitalize}"
      puts "   - Name: #{@options[:name]}"
      puts "   - Base URL: #{@options[:base_url]}"
      puts "   - Routes: #{routes.length}"
      
      route_groups = extractor.extract_route_groups
      puts "   - Controller groups: #{route_groups.length}"
    end
  end
end