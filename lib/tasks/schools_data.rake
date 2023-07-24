# frozen_string_literal: true

GIAS_CSV_PATH = Rails.root.join("data/schools_gias.csv").freeze
PUBLISH_CSV_PATH = Rails.root.join("data/lead_schools_publish.csv").freeze

namespace :schools_data do
  desc "Generate data/schools_gias.csv from GIAS data"
  # NOTE: Academies and free school fields CSV & State-funded school fields CSV
  task :generate_csv_from_gias, %i[gias_csv_1_path gias_csv_2_path output_path] => [:environment] do |_, args|
    items = [args.gias_csv_1_path, args.gias_csv_2_path].flat_map do |csv_path|
      schools = CSV.read(csv_path, headers: true, encoding: "windows-1251:utf-8")

      schools.map do |school|
        town = school["Town"].presence || [school["Address3"], school["Locality"]].detect(&:present?).tap do |backup|
          puts("Town missing for school: '#{school['EstablishmentName']}', estimating as #{backup}")
        end

        {
          urn: school["URN"],
          name: school["EstablishmentName"],
          open_date: school["OpenDate"].presence,
          town: town,
          postcode: school["Postcode"],
        }
      end
    end
    items = items.uniq { |a| a[:urn] }
    items = items.sort { |a, b| a[:urn] <=> b[:urn] }

    puts "Schools total: #{items.count}"
    CSV.open(args.output_path || GIAS_CSV_PATH, "w+") do |csv|
      csv << items.first.keys
      items.each do |hash|
        csv << hash.values
      end
    end
  end

  desc "Import schools from csv data/schools_gias.csv"
  task import_gias: :environment do
    updated = 0
    created = 0

    CSV.read(GIAS_CSV_PATH, headers: true).each do |row|
      school = School.find_or_initialize_by(urn: row["urn"])
      school.id ? updated += 1 : created += 1
      # we don't have data on if the imported school is a lead school or not
      # so we set to false by default, but we don't want to overwrite existing
      school.update!(**row.to_h.except(:urn), lead_school: school.lead_school.present?)
    end

    puts "Done! created: #{created}, updated: #{updated}"
  end

  desc "Generate data/lead_schools_publish.csv from Publish api"
  task :generate_csv_from_publish, %i[output_path] => [:environment] do |_, args|
    request_uri = TeacherTrainingApi::RetrieveLeadSchools::DEFAULT_PATH

    items = []

    while request_uri
      payload = TeacherTrainingApi::RetrieveLeadSchools.call(request_uri:)
      items += payload[:data].map do |provider_data|
        provider_data[:attributes].slice(:urn, :name, :city, :postcode)
      end

      request_uri = payload[:links][:next]
    end

    items = items.uniq { |a| a[:urn] }
    items = items.sort { |a, b| a[:urn] <=> b[:urn] }

    CSV.open(args.output_path || PUBLISH_CSV_PATH, "w+") do |csv|
      csv << items.first.keys
      items.each do |hash|
        csv << hash.values
      end
    end
  end
end
