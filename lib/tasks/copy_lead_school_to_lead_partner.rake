# frozen_string_literal: true

namespace :copy_lead_school_to_lead_partner do
  desc "Copy lead school records to lead partner"
  task copy: :environment do
    CopyLeadSchoolToLeadPartnerService.call
    puts "LeadSchool and LeadSchoolUsers records copied to lead partner successfully."
  end
end
