# frozen_string_literal: true

namespace :schools_data do
  HEADERS = %w[urn name town postcode lead_school open_date close_date].freeze
  REFINED_CSV_PATH = Rails.root.join("data/schools.csv").freeze

  # This task requires two csvs:
  #  The establisment csv can be downloaded here https://get-information-schools.service.gov.uk/Downloads
  #  under "Establishment fields"
  #
  #  Ask in slack for the lead schools csv as it isn't published anywhere

  desc "Trim all establishment csv to only needed columns + flag lead schools"
  task :build_csv, %i[establishment_csv_path lead_schools_csv_path] => [:environment] do |_, args|
    urns = CSV.read(args.lead_schools_csv_path, headers: true).by_col["Lead School (URN)"].uniq
    urns = Set.new(urns)

    schools = CSV.read(args.establishment_csv_path, headers: true, encoding: "windows-1251:utf-8")

    CSV.open(REFINED_CSV_PATH, "w+") do |csv|
      csv << HEADERS
      schools.each do |s|
        lead_school = urns.include? s["URN"]
        town =
          s["Town"].presence || [s["Address3"], s["Locality"]].detect(&:present?).tap do |backup|
            puts "Town missing for school: '#{s['EstablishmentName']}', estimating as #{backup}"
          end

        csv << [s["URN"], s["EstablishmentName"], town, s["Postcode"], lead_school, s["OpenDate"], s["CloseDate"]]
      end
    end
  end

  desc "Import schools from csv data/schools.csv"
  task :import, [:csv_path] => :environment do |_, args|
    csv_path = args.csv_path || REFINED_CSV_PATH
    schools = CSV.read(csv_path, headers: true)

    created = 0
    schools.each do |s|
      School.create!(s.to_h)
      puts "created school with urn: #{s['urn']}"
      created += 1
    end

    puts "Done! #{created} schools created"
  end
end
