# frozen_string_literal: true

require_relative "lib/rails_routes_to_collections/version"

Gem::Specification.new do |spec|
  spec.name = "rails_routes_to_collections"
  spec.version = RailsRoutesToCollections::VERSION
  spec.authors = ["Rails API Collections Generator"]
  spec.email = ["ahmed.abdelatife@gmail.com"]

  spec.summary = "Generate API collections from Rails routes for Postman and Apidog"
  spec.description = "A Ruby gem that extracts Rails routes and generates API collections that can be imported into Postman, Apidog, and other API testing tools"
  spec.homepage = "https://github.com/a-abdellatif98/rails_routes_to_collections"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    files = `git ls-files -z 2>/dev/null`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
    # Add installation scripts
    files += %w[install.rb setup.sh] if File.exist?('install.rb')
    files
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 6.0"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end
