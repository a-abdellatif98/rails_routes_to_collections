# frozen_string_literal: true

require 'json'
require 'securerandom'

module RailsRoutesToCollections
  class PostmanGenerator
    POSTMAN_SCHEMA = 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'

    def initialize(route_extractor)
      @route_extractor = route_extractor
    end

    def generate(collection_name = 'Rails API Routes', base_url = 'http://localhost:3000')
      route_groups = @route_extractor.extract_route_groups

      {
        info: {
          _postman_id: SecureRandom.uuid,
          name: collection_name,
          description: 'Generated from Rails routes',
          schema: POSTMAN_SCHEMA,
          _exporter_id: SecureRandom.uuid
        },
        item: generate_items(route_groups, base_url),
        variable: [
          {
            key: 'base_url',
            value: base_url,
            type: 'string'
          }
        ]
      }
    end

    def generate_json(collection_name = 'Rails API Routes', base_url = 'http://localhost:3000')
      JSON.pretty_generate(generate(collection_name, base_url))
    end

    def write_to_file(filename, collection_name = 'Rails API Routes', base_url = 'http://localhost:3000')
      File.write(filename, generate_json(collection_name, base_url))
    end

    private

    def generate_items(route_groups, base_url)
      route_groups.map do |group|
        {
          name: group[:name],
          item: group[:routes].map { |route| generate_request_item(route, base_url) }
        }
      end
    end

    def generate_request_item(route, base_url)
      {
        name: generate_request_name(route),
        request: {
          method: route[:verb].upcase,
          header: generate_headers(route),
          url: generate_url_object(route, base_url),
          description: generate_description(route)
        },
        response: []
      }
    end

    def generate_request_name(route)
      action_name = route[:action]&.humanize || 'Request'
      controller_name = route[:controller]&.split('/')&.last&.camelize&.gsub(/Controller$/, '') || 'Unknown'
      
      "#{action_name} #{controller_name}"
    end

    def generate_headers(route)
      headers = [
        {
          key: 'Content-Type',
          value: 'application/json',
          type: 'text'
        }
      ]

      # Add Accept header for JSON responses
      if route[:format] == 'json' || route[:path].include?('.json')
        headers << {
          key: 'Accept',
          value: 'application/json',
          type: 'text'
        }
      end

      headers
    end

    def generate_url_object(route, base_url)
      path_parts = route[:path].gsub(/\(\.:format\)$/, '').split('/')
      path_variables = extract_path_variables(route[:path])

      {
        raw: generate_example_url(route[:path], base_url),
        protocol: 'http',
        host: ['{{base_url}}'],
        path: path_parts.reject(&:empty?).map do |part|
          if part.start_with?(':')
            "{{#{part[1..-1]}}}"
          else
            part
          end
        end,
        variable: path_variables
      }
    end

    def extract_path_variables(path)
      variables = []
      path.scan(/:([a-zA-Z_][a-zA-Z0-9_]*)/).flatten.each do |param|
        variables << {
          key: param,
          value: generate_example_value(param),
          description: "Path parameter: #{param}"
        }
      end
      variables
    end

    def generate_example_value(param_name)
      case param_name
      when 'id', 'user_id', 'post_id', /.*_id$/
        '1'
      when 'slug'
        'example-slug'
      when 'token'
        'abc123token'
      when 'email'
        'user@example.com'
      when 'uuid'
        SecureRandom.uuid
      else
        'example-value'
      end
    end

    def generate_example_url(path, base_url)
      example_path = path.gsub(/:([a-zA-Z_][a-zA-Z0-9_]*)/) do |match|
        param_name = match[1..-1]
        generate_example_value(param_name)
      end

      example_path = example_path.gsub(/\(\.:format\)$/, '')
      "#{base_url}#{example_path}"
    end

    def generate_description(route)
      description = "#{route[:verb].upcase} #{route[:path]}\n\n"
      description += "Controller: #{route[:controller]}\n" if route[:controller]
      description += "Action: #{route[:action]}\n" if route[:action]
      description += "Route Name: #{route[:name]}\n" if route[:name]
      
      if route[:constraints] && !route[:constraints].empty?
        description += "\nConstraints:\n"
        route[:constraints].each do |key, value|
          description += "  #{key}: #{value}\n"
        end
      end

      description.strip
    end
  end
end