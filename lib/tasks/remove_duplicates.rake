# frozen_string_literal: true

require "csv"

namespace :trainee do
  desc "Remove duplicate trainees based on email address, given a CSV file with trainee ids"
  task :remove_duplicates, [:file_path] => [:environment] do |_t, args|
    file_path = args[:file_path]

    if file_path.nil? || !File.exist?(file_path)
      puts "Please provide a valid file path with FILE_PATH=<path_to_csv_file>"
      exit 1
    end

    CSV.foreach(file_path, headers: true) do |row|
      trainee_id = row["id"]
      trainee = Trainee.find(trainee_id)

      if trainee.present?
        duplicates = Trainee.where(email: trainee.email).where.not(id: trainee.id)

        duplicates.each do |duplicate|
          duplicate.discard
          puts("Deleted duplicate trainee with id #{duplicate.id} and email #{duplicate.email}")
        rescue StandardError => e
          puts("Failed to delete duplicate trainee with id #{duplicate.id}: #{e.message}")
        end
      else
        puts "Trainee with trainee_id #{trainee_id} not found."
      end
    end

    puts "Task completed."
  end
end
