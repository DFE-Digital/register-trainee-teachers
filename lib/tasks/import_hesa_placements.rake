# frozen_string_literal: true

namespace :import_hesa_placements do
  # Usage: rails import_hesa_placements:from_upload[upload_id]
  # upload_id is the id of an Upload record containing a CSV file with headers
  # hesa_id and urn
  desc "Import HESA placements from uploaded CSV"
  task :from_upload, [:upload_id] => :environment do |_, args|
    upload_id = args.upload_id.to_i
    Placements::ImportFromCsv.call(upload_id:)
  end
end
