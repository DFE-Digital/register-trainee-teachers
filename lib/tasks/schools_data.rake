# frozen_string_literal: true

HEADERS = %w[urn name town postcode lead_school open_date close_date].freeze
REFINED_CSV_PATH = Rails.root.join("data/schools.csv").freeze

namespace :schools_data do
  # This task requires two csvs, see readme under "Regenerating data/schools.csv" for details
  desc "Generate school csv with only the required columns from the establishment and lead school csv"
  task :generate_csv, %i[establishment_csv_path lead_schools_csv_path output_path] => [:environment] do |_, args|
    urns = CSV.read(args.lead_schools_csv_path, headers: true).by_col["Lead School (URN)"]
    urns = Set.new(urns)

    schools = CSV.read(args.establishment_csv_path, headers: true, encoding: "windows-1251:utf-8")

    output_path = args.output_path || REFINED_CSV_PATH

    CSV.open(output_path, "w+") do |csv|
      csv << HEADERS
      schools.each do |school|
        lead_school = urns.include? school["URN"]
        town =
          school["Town"].presence || [school["Address3"], school["Locality"]].detect(&:present?).tap do |backup|
            puts "Town missing for school: '#{school['EstablishmentName']}', estimating as #{backup}"
          end

        csv <<
          [
            school["URN"],
            school["EstablishmentName"],
            town,
            school["Postcode"],
            lead_school,
            school["OpenDate"],
            school["CloseDate"],
          ]
      end
    end
  end

  desc "Import schools from csv data/schools.csv"
  task :import, [:csv_path] => :environment do |_, args|
    csv_path = args.csv_path || REFINED_CSV_PATH
    schools = CSV.read(csv_path, headers: true)

    upserted = 0
    schools.each do |school|
      School.find_or_initialize_by(urn: school["urn"])
        .update!(school.to_h.except(:urn))
      puts "upserted school with urn: #{school['urn']}"
      upserted += 1
    end

    puts "Done! #{upserted} schools upserted"
  end
end
