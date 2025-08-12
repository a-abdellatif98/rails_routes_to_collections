# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-08-12

### Added
- Initial release of rails_routes_to_collections gem
- Rails route extraction functionality 
- Postman collection generation (v2.1.0 format)
- Apidog collection generation
- Command line interface with multiple options
- Rails integration with rake tasks
- Automatic route grouping by controller
- Path parameter detection and example value generation
- Smart route filtering (excludes Rails internal routes)
- Comprehensive test suite with RSpec
- Documentation and usage examples

### Features
- **Multiple Export Formats**: Support for Postman and Apidog collections
- **CLI Tool**: Standalone command-line interface
- **Rails Integration**: Built-in rake tasks for easy Rails workflow integration
- **Smart Grouping**: Automatic organization of routes by controller
- **Parameter Handling**: Automatic detection and example generation for path parameters
- **Filtering**: Intelligent filtering of internal Rails routes and invalid routes
- **Customization**: Configurable collection names, base URLs, and output files