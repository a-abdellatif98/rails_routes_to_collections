#!/usr/bin/env ruby
# frozen_string_literal: true

# Rails Routes to Collections - Installation Test
# This script tests if the gem is properly installed in a Rails project

class InstallationTester
  def initialize(project_path = Dir.pwd)
    @project_path = File.expand_path(project_path)
    @gem_name = 'rails_routes_to_collections'
  end

  def run
    puts "🔍 Testing Rails Routes to Collections Installation"
    puts "=" * 55
    puts "Project: #{@project_path}"
    puts ""

    results = []
    results << test_rails_project
    results << test_gem_presence
    results << test_gemfile_entry
    results << test_cli_script
    results << test_rails_environment
    results << test_gem_functionality

    puts "\n📊 Test Results:"
    puts "=" * 20
    
    passed = results.count(true)
    total = results.length
    
    results.each_with_index do |result, index|
      status = result ? "✅ PASS" : "❌ FAIL"
      test_names = [
        "Rails Project Check",
        "Gem Files Present", 
        "Gemfile Entry",
        "CLI Script",
        "Rails Environment",
        "Gem Functionality"
      ]
      puts "#{status} - #{test_names[index]}"
    end

    puts "\n🎯 Score: #{passed}/#{total} tests passed"
    
    if passed == total
      puts "\n🎉 Installation is working perfectly!"
      puts "\n📋 You can now use:"
      puts "  • bundle exec rails routes:export:postman"
      puts "  • bundle exec rails routes:export:apidog"
      puts "  • ./generate_collections --format postman" if File.exist?(File.join(@project_path, 'generate_collections'))
    else
      puts "\n⚠️  Some issues detected. Please check the failing tests above."
    end
  end

  private

  def test_rails_project
    puts "🔍 Checking if this is a Rails project..."
    
    config_file = File.join(@project_path, 'config', 'application.rb')
    gemfile = File.join(@project_path, 'Gemfile')
    
    if File.exist?(config_file) && File.exist?(gemfile)
      puts "✅ Rails project detected"
      true
    else
      puts "❌ Not a Rails project (missing config/application.rb or Gemfile)"
      false
    end
  end

  def test_gem_presence
    puts "\n🔍 Checking gem files..."
    
    gem_path = File.join(@project_path, 'local_gems', @gem_name)
    lib_path = File.join(gem_path, 'lib', @gem_name + '.rb')
    
    if File.exist?(lib_path)
      puts "✅ Gem files found at #{gem_path}"
      true
    else
      puts "❌ Gem files not found. Expected at: #{gem_path}"
      false
    end
  end

  def test_gemfile_entry
    puts "\n🔍 Checking Gemfile entry..."
    
    gemfile_path = File.join(@project_path, 'Gemfile')
    return false unless File.exist?(gemfile_path)
    
    gemfile_content = File.read(gemfile_path)
    
    if gemfile_content.include?(@gem_name)
      puts "✅ Gem entry found in Gemfile"
      true
    else
      puts "❌ Gem not found in Gemfile"
      false
    end
  end

  def test_cli_script
    puts "\n🔍 Checking CLI script..."
    
    cli_script = File.join(@project_path, 'generate_collections')
    
    if File.exist?(cli_script) && File.executable?(cli_script)
      puts "✅ CLI script found and executable"
      true
    else
      puts "⚠️  CLI script not found (optional)"
      true  # This is optional, so we pass
    end
  end

  def test_rails_environment
    puts "\n🔍 Testing Rails environment loading..."
    
    begin
      # Change to project directory
      Dir.chdir(@project_path) do
        # Add gem to load path
        gem_lib_path = File.join('local_gems', @gem_name, 'lib')
        $LOAD_PATH.unshift(File.expand_path(gem_lib_path)) if File.exist?(gem_lib_path)
        
        # Try to load Rails environment
        require_relative File.join(@project_path, 'config', 'environment')
        
        if defined?(Rails) && Rails.application
          puts "✅ Rails environment loaded successfully"
          true
        else
          puts "❌ Rails environment failed to load properly"
          false
        end
      end
    rescue => e
      puts "❌ Rails environment loading failed: #{e.message}"
      false
    end
  end

  def test_gem_functionality
    puts "\n🔍 Testing gem functionality..."
    
    begin
      Dir.chdir(@project_path) do
        # Add gem to load path
        gem_lib_path = File.join('local_gems', @gem_name, 'lib')
        $LOAD_PATH.unshift(File.expand_path(gem_lib_path)) if File.exist?(gem_lib_path)
        
        require @gem_name
        
        # Test basic functionality
        extractor = RailsRoutesToCollections::RouteExtractor.new
        routes = extractor.extract_routes
        
        puts "✅ Gem loaded and extracted #{routes.length} routes"
        true
      end
    rescue => e
      puts "❌ Gem functionality test failed: #{e.message}"
      false
    end
  end
end

# Run the test
if ARGV.first == '--help' || ARGV.first == '-h'
  puts "Usage: ruby test_installation.rb [project_path]"
  puts ""
  puts "Tests if rails_routes_to_collections gem is properly installed."
  puts "If no project_path is provided, tests current directory."
  exit
end

project_path = ARGV.first || Dir.pwd
InstallationTester.new(project_path).run