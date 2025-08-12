# frozen_string_literal: true

require 'rails/railtie'

module RailsRoutesToCollections
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('tasks/routes_to_collections.rake', __dir__)
    end
  end
end