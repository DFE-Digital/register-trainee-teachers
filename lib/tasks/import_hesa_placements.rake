# frozen_string_literal: true

namespace :import_hesa_placements do
  # Usage: rails import_hesa_placements:from_upload[upload_id]
  # upload_id is the id of an Upload record containing a CSV file with headers
  # hesa_id and urn
  desc "Import HESA placements from uploaded CSV"
  task :from_upload, [:upload_id] => :environment do |_, args|
    upload_id = args.upload_id.to_i
    import = Placements::ImportFromCsv.call(upload_id:)

    puts("")
    puts("HESA ids which don't match any trainees in Register:")
    import.unmatched_hesa_ids.uniq.each do |hesa_id|
      puts("  hesa_id: #{hesa_id}")
    end

    puts("")
    puts("URNs which don't match any Schools in Register:")
    import.unmatched_urns.uniq.each do |urn|
      puts("  URN: #{urn}")
    end

    puts("")
    puts("Total number of rows not imported: #{(import.unmatched_hesa_ids.count + import.unmatched_urns.count).to_fs(:delimited)}")
  end
end
