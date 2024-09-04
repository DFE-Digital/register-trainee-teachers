# frozen_string_literal: true

namespace :trainees do
  desc "creates trainees from apply"
  task :create_from_apply, %i[recruitment_cycle_year] => [:environment] do |_, args|
    recruitment_cycle_year = args.recruitment_cycle_year

    changed_since = ApplyApplicationSyncRequest
    .successful
    .where(recruitment_cycle_year:)
    .maximum(:created_at)

    raise "No viable recruitment_cycle_year inputted" if recruitment_cycle_year.blank?

    raise "No viable changed_since found" if changed_since.blank?

    RecruitsApi::RetrieveApplications.call(changed_since:, recruitment_cycle_year:).each do |application_data|
      application = RecruitsApi::ImportApplication.call(application_data:)

      Trainees::CreateFromApply.call(application:) if application&.importable? && application&.provider&.apply_sync_enabled
    end
  end
end
