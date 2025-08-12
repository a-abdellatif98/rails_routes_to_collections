# frozen_string_literal: true

RSpec.describe RailsRoutesToCollections::ApidogGenerator do
  let(:mock_extractor) do
    double('RouteExtractor', extract_route_groups: [
      {
        name: 'Users',
        routes: [
          {
            name: 'users_index',
            verb: 'GET',
            path: '/users',
            controller: 'users',
            action: 'index',
            constraints: {},
            format: nil
          },
          {
            name: 'user_create',
            verb: 'POST',
            path: '/users',
            controller: 'users',
            action: 'create',
            constraints: {},
            format: nil
          }
        ]
      }
    ])
  end

  let(:generator) { described_class.new(mock_extractor) }

  describe '#generate' do
    let(:collection) { generator.generate('Test Collection', 'https://api.example.com') }

    it 'generates a valid Apidog collection structure' do
      expect(collection).to have_key(:apidogVersion)
      expect(collection).to have_key(:type)
      expect(collection).to have_key(:name)
      expect(collection).to have_key(:folders)
      expect(collection).to have_key(:apis)
      expect(collection).to have_key(:variables)
    end

    it 'sets correct collection metadata' do
      expect(collection[:apidogVersion]).to eq('1.0.0')
      expect(collection[:type]).to eq('collection')
      expect(collection[:name]).to eq('Test Collection')
      expect(collection[:description]).to eq('Generated from Rails routes using rails_routes_to_collections gem')
    end

    it 'includes base_url variable' do
      variables = collection[:variables]
      base_url_var = variables.find { |v| v[:key] == 'base_url' }
      expect(base_url_var[:value]).to eq('https://api.example.com')
    end

    it 'generates folders for route groups' do
      folders = collection[:folders]
      expect(folders).to be_an(Array)
      expect(folders.first[:name]).to eq('Users')
      expect(folders.first[:id]).to eq('folder_0')
    end

    it 'generates APIs for routes' do
      apis = collection[:apis]
      expect(apis).to be_an(Array)
      expect(apis.length).to eq(2)
      
      get_api = apis.first
      expect(get_api[:method]).to eq('GET')
      expect(get_api[:name]).to eq('Index Users')
      
      post_api = apis.last
      expect(post_api[:method]).to eq('POST')
      expect(post_api[:name]).to eq('Create Users')
      expect(post_api[:requestBody]).to have_key(:type)
    end
  end

  describe '#generate_json' do
    it 'returns valid JSON string' do
      json_string = generator.generate_json
      expect { JSON.parse(json_string) }.not_to raise_error
    end
  end
end