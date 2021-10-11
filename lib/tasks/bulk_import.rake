# frozen_string_literal: true

namespace :bulk_import do
  desc "imports a csv of trainees from a provided csv"
  task :import, %i[provider_code csv_path] => [:environment] do |_, args|
    csv = CSV.read(args.csv_path, headers: true, encoding: "ISO-8859-1")
    error_rows = []

    provider = Provider.find_by!(code: args.provider_code)

    csv.each_with_index do |row, i|
      error_row = BulkImport.import_row(provider, row)
      if error_row.present?
        error_rows << error_row
      end
    rescue StandardError => e
      puts("error on row #{i + 1}: #{e.message}")
      Sentry.capture_exception(e)
    end
  end
end
