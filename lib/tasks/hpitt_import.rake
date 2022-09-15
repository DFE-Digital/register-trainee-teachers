# frozen_string_literal: true

namespace :hpitt do
  desc "imports a csv of trainees from HPITT"
  task :import, %i[csv_path] => [:environment] do |_, args|
    csv = CSV.read(
      args.csv_path,
      headers: true,
      encoding: "ISO-8859-1",
      header_converters: ->(f) { f&.strip },
    )

    csv.each_with_index do |row, i|
      Trainees::CreateFromHpittCsv.call(csv_row: row)
    rescue StandardError => e
      Rails.logger.error("error on row #{i + 1}: #{e.message}")
      Sentry.capture_exception(e)
    end
  end
end
