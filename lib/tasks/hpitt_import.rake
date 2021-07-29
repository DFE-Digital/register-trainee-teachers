# frozen_string_literal: true

namespace :hpitt do
  desc "imports a csv of trainees from hoppit"
  task :import, %i[csv_path] => [:environment] do |_, args|
    csv = CSV.read(args.csv_path, headers: true)
    ActiveRecord::Base.transaction do
      csv.each_with_index do |row, i|
        HPITT.import_row row
      rescue StandardError => e
        message = "error on row #{i + 1}: #{e.message}"
        raise HPITT::Error, message
      end
    end
  end
end
