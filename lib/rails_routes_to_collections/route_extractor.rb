# frozen_string_literal: true

module RailsRoutesToCollections
  class RouteExtractor
    def initialize(app = Rails.application)
      @app = app
    end

    def extract_routes
      @app.routes.routes.map do |route|
        next unless route.verb.present? && route.path.present?

        {
          name: route.name,
          verb: route.verb.gsub(/\^|\$/, '').split('|').first, # Clean HTTP verb
          path: route.path.spec.to_s,
          controller: route.defaults[:controller],
          action: route.defaults[:action],
          constraints: route.constraints,
          format: route.defaults[:format]
        }
      end.compact.select { |route| valid_route?(route) }
    end

    def extract_route_groups
      routes = extract_routes
      grouped = routes.group_by { |route| route[:controller] }

      grouped.map do |controller, controller_routes|
        {
          name: humanize_controller_name(controller),
          folder: true,
          routes: controller_routes
        }
      end
    end

    private

    def valid_route?(route)
      # Filter out internal Rails routes and invalid routes
      return false if route[:controller].nil?
      return false if route[:controller].start_with?('rails/')
      return false if route[:path].include?('(*')
      return false if route[:verb].blank?
      
      true
    end

    def humanize_controller_name(controller_name)
      return 'Unknown' unless controller_name

      controller_name.split('/')
                    .map { |part| part.camelize.gsub(/Controller$/, '') }
                    .join(' / ')
    end

    def parse_path_parameters(path)
      path.scan(/:([a-zA-Z_][a-zA-Z0-9_]*)/).flatten
    end

    def generate_example_url(path, base_url = 'http://localhost:3000')
      example_path = path.gsub(/:([a-zA-Z_][a-zA-Z0-9_]*)/) do |match|
        param_name = match[1..-1]
        case param_name
        when 'id', 'user_id', 'post_id' then '1'
        when 'slug' then 'example-slug'
        when 'token' then 'abc123'
        else 'example'
        end
      end

      # Remove format specification
      example_path = example_path.gsub(/\(\.:format\)$/, '')
      "#{base_url}#{example_path}"
    end
  end
end