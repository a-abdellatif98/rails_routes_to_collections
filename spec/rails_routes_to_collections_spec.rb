# frozen_string_literal: true

RSpec.describe RailsRoutesToCollections do
  it "has a version number" do
    expect(RailsRoutesToCollections::VERSION).not_to be nil
  end

  describe "module structure" do
    it "defines the main components" do
      expect(defined?(RailsRoutesToCollections::RouteExtractor)).to be_truthy
      expect(defined?(RailsRoutesToCollections::PostmanGenerator)).to be_truthy
      expect(defined?(RailsRoutesToCollections::ApidogGenerator)).to be_truthy
      expect(defined?(RailsRoutesToCollections::CLI)).to be_truthy
    end

    it "defines custom error class" do
      expect(RailsRoutesToCollections::Error).to be < StandardError
    end
  end
end