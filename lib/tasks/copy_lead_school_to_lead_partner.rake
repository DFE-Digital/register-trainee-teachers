# frozen_string_literal: true

namespace :copy_lead_school_to_lead_partner do
  desc "Copy lead school records to lead partner"
  task copy: :environment do
    CopyLeadSchoolToLeadPartnerService.new.call
    puts "Lead school records copied to lead partner successfully."
  end
end
