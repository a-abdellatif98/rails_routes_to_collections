# frozen_string_literal: true

RSpec.describe RailsRoutesToCollections::PostmanGenerator do
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
            name: 'user_show',
            verb: 'GET',
            path: '/users/:id',
            controller: 'users',
            action: 'show',
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

    it 'generates a valid Postman collection structure' do
      expect(collection).to have_key(:info)
      expect(collection).to have_key(:item)
      expect(collection).to have_key(:variable)
    end

    it 'sets correct collection metadata' do
      info = collection[:info]
      expect(info[:name]).to eq('Test Collection')
      expect(info[:description]).to eq('Generated from Rails routes')
      expect(info[:schema]).to eq(RailsRoutesToCollections::PostmanGenerator::POSTMAN_SCHEMA)
    end

    it 'includes base_url variable' do
      variables = collection[:variable]
      base_url_var = variables.find { |v| v[:key] == 'base_url' }
      expect(base_url_var[:value]).to eq('https://api.example.com')
    end

    it 'generates items for route groups' do
      items = collection[:item]
      expect(items).to be_an(Array)
      expect(items.first[:name]).to eq('Users')
      expect(items.first[:item]).to be_an(Array)
      expect(items.first[:item].length).to eq(2)
    end

    it 'generates proper request items' do
      request_item = collection[:item].first[:item].first
      expect(request_item[:name]).to eq('Index Users')
      expect(request_item[:request][:method]).to eq('GET')
      expect(request_item[:request][:url][:raw]).to eq('https://api.example.com/users')
    end
  end

  describe '#generate_json' do
    it 'returns valid JSON string' do
      json_string = generator.generate_json
      expect { JSON.parse(json_string) }.not_to raise_error
    end
  end
end