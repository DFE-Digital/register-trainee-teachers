# frozen_string_literal: true

GIAS_CSV_PATH = Rails.root.join("data/schools_gias.csv").freeze

namespace :schools_data do
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
end
