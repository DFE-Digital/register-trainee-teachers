# frozen_string_literal: true

namespace :create_trainees_from_csv do
  desc "creates teach first trainees from a CSV"
  task :teach_first, %i[csv_path] => [:environment] do |_, args|
    csv = CSV.read(
      args.csv_path,
      headers: true,
      encoding: "ISO-8859-1",
      header_converters: ->(f) { f&.strip },
    )

    csv.each_with_index do |csv_row, i|
      Trainees::CreateFromCsvRow::TeachFirst.call(csv_row:)
    rescue StandardError => e
      Rails.logger.error("error on row #{i + 1}: #{e.message}")
      Sentry.capture_exception(e)
    end
  end

  desc "creates ambition trainees from a CSV"
  task :ambition, %i[csv_path] => [:environment] do |_, args|
    csv = CSV.read(
      args.csv_path,
      headers: true,
      encoding: "ISO-8859-1",
      header_converters: ->(f) { f&.strip },
    )

    csv.each_with_index do |csv_row, i|
      Trainees::CreateFromCsvRow::Ambition.call(csv_row:)
    rescue StandardError => e
      Rails.logger.error("error on row #{i + 1}: #{e.message}")
      Sentry.capture_exception(e)
    end
  end
end
