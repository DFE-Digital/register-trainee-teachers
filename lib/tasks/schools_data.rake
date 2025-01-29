# frozen_string_literal: true

GIAS_CSV_PATH = Rails.root.join("data/schools_gias.csv").freeze

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
      school.update!(**row.to_h.except(:urn))
    end

    puts "Done! created: #{created}, updated: #{updated}"
  end

  desc "Realign lead partner with school name"
  task :realign_lead_partner_with_school_name do
    success_count = 0
    lead_partners = LeadPartner.school.joins(:school).where("lead_partners.name != schools.name")

    lead_partners.find_each do |lead_partner|
      puts "Updating: '#{lead_partner.name}' to '#{lead_partner.school.name}'"
      lead_partner.name = lead_partner.school.name
      if lead_partner.save
        success_count += 1
      end
    end

    puts "Done! updated: #{success_count}"
  end
end
