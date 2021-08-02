# frozen_string_literal: true

namespace :hpitt do
  desc "imports a csv of trainees from hoppit"
  task :import, %i[csv_path] => [:environment] do |_, args|
    csv = CSV.read(args.csv_path, headers: true)
    error_rows = []

    csv.each_with_index do |row, i|
      error_row = HPITT.import_row row
      if error_row.present?
        error_rows << error_row
      end
    rescue StandardError => e
      puts "error on row #{i + 1}: #{e.message}"
    end
  end
end
