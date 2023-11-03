# frozen_string_literal: true

namespace :country_autocomplete_graph do
  desc "Regenerate public/location-autocomplete-graph.json"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    require "dfe/reference_data/countries_and_territories"

    graph_file_name = "location-autocomplete-graph.json"
    node_plugin_path = "node_modules/govuk-country-and-territory-autocomplete/dist"
    original_location_graph = JSON.parse(Rails.root.join(node_plugin_path, graph_file_name).read)

    dfe_reference_location_graph = {}
    missing_from_dfe_reference = {}

    DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES.all.each do |reference| # rubocop:disable Rails/FindEach
      results = {}
      country_code = reference.id
      country_key = "country:#{reference.name}"
      territory_key = "territory:#{country_code}"

      original_location_graph.each do |key, value|
        child_nodes = value.dig("edges", "from").join
        next unless key == country_key ||
          key == territory_key ||
          child_nodes.include?(country_key) ||
          child_nodes.include?(territory_key)

        results[key] = value
      end

      dfe_reference_location_graph.merge!(results)
    end

    (original_location_graph.keys - dfe_reference_location_graph.keys).each do |primary_key|
      missing_from_dfe_reference[primary_key] = original_location_graph[primary_key]
    end

    Rails.public_path.join(graph_file_name).write(dfe_reference_location_graph.to_json)

    Rails.root.join("missing-location-graph-from-dfe-reference.json").write(missing_from_dfe_reference.to_json)
  end
end
