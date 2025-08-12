# Rails Routes to Collections

[![Gem Version](https://badge.fury.io/rb/rails_routes_to_collections.svg)](https://badge.fury.io/rb/rails_routes_to_collections)

A Ruby gem that generates API collections from Rails routes that can be imported into Postman, Apidog, and other API testing tools.

## Features

- 🚀 **Easy Installation**: Works as a gem in any Rails application
- 📊 **Multiple Formats**: Generates collections for Postman and Apidog
- 🔧 **CLI Interface**: Use from command line or integrate into your workflow
- 📋 **Rake Tasks**: Built-in Rails integration with rake tasks
- 🎯 **Smart Grouping**: Automatically groups routes by controller
- 📝 **Rich Metadata**: Includes route names, HTTP methods, parameters, and more
- 🔗 **Example Values**: Automatically generates example parameter values

## Installation

Add this line to your Rails application's Gemfile:

```ruby
gem 'rails_routes_to_collections'
```

And then execute:

```bash
$ bundle install
```

Or install it globally:

```bash
$ gem install rails_routes_to_collections
```

## Usage

### Command Line Interface

Navigate to your Rails application directory and run:

```bash
# Generate Postman collection
$ rails_routes_to_collections --format postman

# Generate Apidog collection
$ rails_routes_to_collections --format apidog

# Specify output file and collection name
$ rails_routes_to_collections --format postman --output my_api.json --name "My API" --base-url https://api.example.com
```

### CLI Options

- `-f, --format FORMAT`: Output format (`postman`, `apidog`) - default: `postman`
- `-o, --output FILE`: Output file path - default: auto-generated filename
- `-n, --name NAME`: Collection name - default: `'Rails API Routes'`
- `-u, --base-url URL`: Base URL for the API - default: `'http://localhost:3000'`
- `-h, --help`: Show help message
- `-v, --version`: Show version

### Rake Tasks

The gem automatically adds rake tasks to your Rails application:

```bash
# Generate Postman collection
$ rails routes:export:postman

# Generate Apidog collection  
$ rails routes:export:apidog

# Generate both formats
$ rails routes:export:all

# With custom parameters
$ rails routes:export:postman[my_postman_collection.json,"My API","https://api.example.com"]
```

### Programmatic Usage

```ruby
require 'rails_routes_to_collections'

# Initialize components
extractor = RailsRoutesToCollections::RouteExtractor.new
postman_generator = RailsRoutesToCollections::PostmanGenerator.new(extractor)
apidog_generator = RailsRoutesToCollections::ApidogGenerator.new(extractor)

# Generate collections
postman_collection = postman_generator.generate('My API', 'https://api.example.com')
apidog_collection = apidog_generator.generate('My API', 'https://api.example.com')

# Save to files
postman_generator.write_to_file('postman.json', 'My API', 'https://api.example.com')
apidog_generator.write_to_file('apidog.json', 'My API', 'https://api.example.com')

# Get as JSON string
postman_json = postman_generator.generate_json('My API', 'https://api.example.com')
apidog_json = apidog_generator.generate_json('My API', 'https://api.example.com')
```

## Generated Collection Structure

### Postman Collections

The generated Postman collections follow the [Postman Collection Format v2.1.0](https://schema.postman.com/) and include:

- Collection metadata (name, description, schema)
- Environment variables (base_url)
- Organized folders by controller
- Request details with proper HTTP methods
- Path parameters with example values
- Appropriate headers (Content-Type, Accept)
- Request descriptions with route metadata

### Apidog Collections  

The generated Apidog collections follow Apidog's format specification and include:

- Collection metadata with timestamps
- Environment variables
- Organized folders by controller  
- API definitions with full metadata
- Path and query parameters with types
- Request/response body templates
- Tags for better organization

## Route Filtering

The gem automatically filters out:

- Internal Rails routes (starting with `rails/`)
- Invalid or malformed routes
- Routes without HTTP verbs
- Catch-all routes with `(*path)`

## Example Output

For a Rails app with these routes:

```ruby
Rails.application.routes.draw do
  resources :users do
    resources :posts
  end
  get '/health', to: 'health#check'
end
```

The gem will generate organized collections with requests like:

- **Users**
  - Index Users (`GET /users`)
  - Show User (`GET /users/:id`)  
  - Create User (`POST /users`)
  - Update User (`PUT /users/:id`)
  - Delete User (`DELETE /users/:id`)

- **Posts**  
  - Index Posts (`GET /users/:user_id/posts`)
  - Show Post (`GET /users/:user_id/posts/:id`)
  - Create Post (`POST /users/:user_id/posts`)
  - Update Post (`PUT /users/:user_id/posts/:id`)
  - Delete Post (`DELETE /users/:user_id/posts/:id`)

- **Health**
  - Check Health (`GET /health`)

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.0

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/example/rails_routes_to_collections. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Roadmap

- [ ] Support for OpenAPI/Swagger format
- [ ] Custom route filtering options
- [ ] Request body generation based on strong parameters
- [ ] Integration with more API testing tools
- [ ] GraphQL schema export support