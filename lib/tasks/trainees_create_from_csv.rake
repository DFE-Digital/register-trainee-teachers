# frozen_string_literal: true

namespace :trainees do
  desc "creates trainees from a CSV"
  task :create_from_csv, %i[provider_code csv_path] => [:environment] do |_, args|
    csv = CSV.read(
      args.csv_path,
      headers: true,
      encoding: "ISO-8859-1",
      header_converters: ->(f) { f&.strip },
    )

    provider = Provider.find_by!(code: args.provider_code)

    csv.each_with_index do |row, i|
      Trainees::CreateFromCsvRow.call(provider: provider, csv_row: row)
    rescue StandardError => e
      Rails.logger.error("error on row #{i + 1}: #{e.message}")
      Sentry.capture_exception(e)
    end

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Provider not found with code #{args.provider_code}")
    Sentry.capture_exception(e)
  end
end
