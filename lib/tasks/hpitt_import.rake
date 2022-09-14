# frozen_string_literal: true

namespace :hpitt do
  desc "imports a csv of trainees from hppit"
  task :import, %i[csv_path] => [:environment] do |_, args|
    csv = CSV.read(args.csv_path, headers: true, encoding: "ISO-8859-1")
    error_rows = []

    csv.each_with_index do |row, i|
      error_row = Trainees::CreateFromHpittCsv.call(csv_row: row)
      if error_row.present?
        error_rows << error_row
      end
    rescue StandardError => e
      Rails.logger.error("error on row #{i + 1}: #{e.message}")
      Sentry.capture_exception(e)
    end
  end
end
