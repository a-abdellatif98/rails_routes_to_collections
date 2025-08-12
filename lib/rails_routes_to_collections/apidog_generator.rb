# frozen_string_literal: true

require 'json'
require 'securerandom'

module RailsRoutesToCollections
  class ApidogGenerator
    def initialize(route_extractor)
      @route_extractor = route_extractor
    end

    def generate(collection_name = 'Rails API Routes', base_url = 'http://localhost:3000')
      route_groups = @route_extractor.extract_route_groups

      {
        apidogVersion: '1.0.0',
        type: 'collection',
        name: collection_name,
        description: 'Generated from Rails routes using rails_routes_to_collections gem',
        createdTime: Time.now.to_i,
        updatedTime: Time.now.to_i,
        variables: [
          {
            key: 'base_url',
            value: base_url,
            type: 'string',
            description: 'Base URL for the API'
          }
        ],
        folders: generate_folders(route_groups),
        apis: generate_apis(route_groups, base_url)
      }
    end

    def generate_json(collection_name = 'Rails API Routes', base_url = 'http://localhost:3000')
      JSON.pretty_generate(generate(collection_name, base_url))
    end

    def write_to_file(filename, collection_name = 'Rails API Routes', base_url = 'http://localhost:3000')
      File.write(filename, generate_json(collection_name, base_url))
    end

    private

    def generate_folders(route_groups)
      route_groups.map.with_index do |group, index|
        {
          id: "folder_#{index}",
          name: group[:name],
          description: "APIs for #{group[:name]} controller",
          createdTime: Time.now.to_i,
          updatedTime: Time.now.to_i
        }
      end
    end

    def generate_apis(route_groups, base_url)
      apis = []
      
      route_groups.each_with_index do |group, folder_index|
        group[:routes].each_with_index do |route, api_index|
          apis << generate_api_item(route, base_url, "folder_#{folder_index}", "#{folder_index}_#{api_index}")
        end
      end
      
      apis
    end

    def generate_api_item(route, base_url, folder_id, api_id)
      {
        id: "api_#{api_id}",
        folderId: folder_id,
        name: generate_api_name(route),
        description: generate_description(route),
        method: route[:verb].upcase,
        url: generate_url_with_variables(route, base_url),
        headers: generate_headers(route),
        pathParams: generate_path_params(route),
        queryParams: [],
        requestBody: generate_request_body(route),
        responses: [generate_default_response],
        createdTime: Time.now.to_i,
        updatedTime: Time.now.to_i,
        tags: generate_tags(route)
      }
    end

    def generate_api_name(route)
      action_name = route[:action]&.humanize || 'Request'
      controller_name = route[:controller]&.split('/')&.last&.camelize&.gsub(/Controller$/, '') || 'Unknown'
      
      "#{action_name} #{controller_name}"
    end

    def generate_url_with_variables(route, base_url)
      # Replace path parameters with Apidog variable syntax
      url_path = route[:path].gsub(/:([a-zA-Z_][a-zA-Z0-9_]*)/, '{{\\1}}')
      url_path = url_path.gsub(/\(\.:format\)$/, '')
      
      "{{base_url}}#{url_path}"
    end

    def generate_headers(route)
      headers = []

      # Add Content-Type for methods that typically send data
      if %w[POST PUT PATCH].include?(route[:verb].upcase)
        headers << {
          key: 'Content-Type',
          value: 'application/json',
          type: 'text',
          description: 'Request content type'
        }
      end

      # Add Accept header for JSON responses
      if route[:format] == 'json' || route[:path].include?('.json')
        headers << {
          key: 'Accept',
          value: 'application/json',
          type: 'text',
          description: 'Response content type'
        }
      end

      headers
    end

    def generate_path_params(route)
      params = []
      route[:path].scan(/:([a-zA-Z_][a-zA-Z0-9_]*)/).flatten.each do |param|
        params << {
          key: param,
          value: generate_example_value(param),
          type: determine_param_type(param),
          description: "Path parameter: #{param}",
          required: true
        }
      end
      params
    end

    def generate_request_body(route)
      return nil unless %w[POST PUT PATCH].include?(route[:verb].upcase)

      {
        type: 'json',
        jsonBody: generate_sample_json_body(route)
      }
    end

    def generate_sample_json_body(route)
      controller_name = route[:controller]&.split('/')&.last&.gsub(/_controller$/, '')
      
      case route[:action]
      when 'create'
        {
          "#{controller_name&.singularize || 'resource'}" => {
            'name' => 'Example Name',
            'description' => 'Example Description'
          }
        }
      when 'update'
        {
          "#{controller_name&.singularize || 'resource'}" => {
            'name' => 'Updated Name',
            'description' => 'Updated Description'
          }
        }
      else
        {
          'data' => 'Example request body'
        }
      end
    end

    def generate_default_response
      {
        name: 'Success',
        status: 200,
        contentType: 'application/json',
        body: JSON.pretty_generate({
          success: true,
          data: {},
          message: 'Request processed successfully'
        }),
        headers: [
          {
            key: 'Content-Type',
            value: 'application/json'
          }
        ]
      }
    end

    def generate_tags(route)
      tags = []
      
      if route[:controller]
        controller_parts = route[:controller].split('/')
        tags.concat(controller_parts.map(&:humanize))
      end
      
      tags << route[:action].humanize if route[:action]
      tags << route[:verb].upcase
      
      tags.uniq
    end

    def generate_example_value(param_name)
      case param_name
      when 'id', 'user_id', 'post_id', /.*_id$/
        1
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

    def determine_param_type(param_name)
      case param_name
      when 'id', /.*_id$/
        'number'
      when 'email'
        'string'
      when 'uuid'
        'string'
      else
        'string'
      end
    end

    def generate_description(route)
      description = "#{route[:verb].upcase} #{route[:path]}\n\n"
      description += "**Controller:** #{route[:controller]}\n" if route[:controller]
      description += "**Action:** #{route[:action]}\n" if route[:action]
      description += "**Route Name:** #{route[:name]}\n" if route[:name]
      
      if route[:constraints] && !route[:constraints].empty?
        description += "\n**Constraints:**\n"
        route[:constraints].each do |key, value|
          description += "- #{key}: #{value}\n"
        end
      end

      description.strip
    end
  end
end