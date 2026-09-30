# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

require_relative "rails_routes_to_collections/version"
require_relative "rails_routes_to_collections/route_extractor"
require_relative "rails_routes_to_collections/postman_generator"
require_relative "rails_routes_to_collections/apidog_generator"
require_relative "rails_routes_to_collections/cli"

if defined?(Rails::Railtie)
  require_relative "rails_routes_to_collections/railtie"
end

module RailsRoutesToCollections
  class Error < StandardError; end
end