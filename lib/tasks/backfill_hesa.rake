# frozen_string_literal: true

namespace :backfill_hesa do
  namespace :degrees do
    task from_source: :environment do |_, _args|
      ::Hesa::BackfillDegrees.call
    end

    task :from_upload, [:upload_id] => :environment do |_, args|
      ::Hesa::BackfillDegrees.call(upload_id: args.upload_id.to_i)
    end
  end
end
