# frozen_string_literal: true

namespace :create_trainees_from_csv do
  desc "Creates trainees from an Upload CSV"
  task :process, %i[upload_id type] => [:environment] do |_, args|
    upload = Upload.find(args.upload_id)

    unless args.type == "teach_first"
      puts "Invalid type. Please specify 'teach_first'."
      exit
    end

    processor = "Trainees::CreateFromCsvRow::#{args.type.camelize}".constantize

    upload.file.blob.open do |tempfile|
      CSV.foreach(
        tempfile.path,
        headers: true,
        header_converters: ->(f) { f&.strip },
      ).with_index(2) do |csv_row, i|
        processor.call(csv_row:)
      rescue StandardError => e
        puts("Error on row #{i}: #{e.message}")
        Rails.logger.error("Error on row #{i}: #{e.message}")
        Sentry.capture_exception(e)
      end
    end
  end
end
