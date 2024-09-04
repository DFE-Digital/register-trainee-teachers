# frozen_string_literal: true

namespace :trainees do
  desc "creates trainees from apply"
  task :create_from_apply, %i[recruitment_cycle_year] => [:environment] do |_, args|
    recruitment_cycle_year = args.recruitment_cycle_year

    changed_since = ApplyApplicationSyncRequest
    .successful
    .where(recruitment_cycle_year:)
    .maximum(:created_at)

    if recruitment_cycle_year.blank? || changed_since.blank?
      puts "No viable recruitment_cycle_year inputted or changed_since found"
      exit 1
    end

    RecruitsApi::RetrieveApplications.call(changed_since:, recruitment_cycle_year:).each do |application_data|
      application = ImportApplication.call(application_data:)

      CreateFromApply.call(application:) if application&.importable? && application&.provider&.apply_sync_enabled
    end
  end
end
