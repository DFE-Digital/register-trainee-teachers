# frozen_string_literal: true

namespace :country_autocomplete_graph do
  desc "Regenerate public/location-autocomplete-graph.json"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    graph_file_name = "location-autocomplete-graph.json"
    node_plugin_path = "node_modules/govuk-country-and-territory-autocomplete/dist"
    original_location_graph = JSON.parse(File.read(Rails.root.join(node_plugin_path, graph_file_name)))

    dttp_location_graph = {}
    missing_from_dttp = {}

    Dttp::CodeSets::Countries::MAPPING.each do |_, meta|
      results = {}
      country_code = meta[:country_code]
      primary_key = "country:#{country_code}"

      original_location_graph.each do |key, value|
        inbound_nodes = value.dig("edges", "from").join
        if key == primary_key || inbound_nodes.include?(primary_key) || inbound_nodes.include?("#{country_code.downcase}:")
          results[key] = value
        end
      end

      dttp_location_graph.merge!(results)
    end

    (original_location_graph.keys - dttp_location_graph.keys).each do |primary_key|
      missing_from_dttp[primary_key] = original_location_graph[primary_key]
    end

    File.open(Rails.root.join("public", graph_file_name), "w") do |f|
      f.write(dttp_location_graph.to_json)
    end

    File.open(Rails.root.join("missing-location-graph-from-dttp.json"), "w") do |f|
      f.write(missing_from_dttp.to_json)
    end
  end
end
