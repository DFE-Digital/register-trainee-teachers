# frozen_string_literal: true

namespace :diversity do
  desc "imports ethnicity from a csv with trainee_id and ethnicity headers"
  task :ethnicity, %i[file_name provider_code] => :environment do |_, args|
    # make sure you've uploaded a CSV via /system-admin/uploads
    AddEthnicityFromCsv.new(file_name: args.file_name, provider_code: args.provider_code).call
  end
end
