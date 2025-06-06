# frozen_string_literal: true

namespace :csv do
  desc "convert all CSV fixtures to use apostrophe prefixes where required"
  task prefix_all: :environment do
    all_files = Dir.glob(File.join(Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/"), "*.csv"))

    all_files.each do |file|
      puts "Processing file: #{file}"

      # Read the file and convert the values as required
      prefixed_rows = []
      CSV.open(file, "r", headers: true).each do |row|
        prefixed_row = {}
        row.to_h.each do |key, value|
          prefixed_value = if key.in?(BulkUpdate::AddTrainees::ImportRows::PREFIXED_HEADERS) &&
              value.is_a?(String) &&
              value.present? &&
              !value.start_with?("'")
            "'#{value}"
          else
            value
          end
          prefixed_row[key] = prefixed_value
        end
        prefixed_rows << prefixed_row
      end

      # Write the updated content back to the file
      CSV.open(file, "w") do |csv|
        csv << BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys
        prefixed_rows.each { |row| csv << row.values }
      end
    end
  end
end
