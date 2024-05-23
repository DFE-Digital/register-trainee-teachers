# frozen_string_literal: true

class CopyLeadSchoolToLeadPartnerService
  include ServicePattern

  def call
    School.lead_only.find_each do |school|
      lead_partner = LeadPartner.find_or_create_by!(urn: school.urn, school_id: school.id) do |lp|
        lp.name = school.name
        lp.record_type = LeadPartner::LEAD_SCHOOL
      end

      # Ensure lead_partner_users are up-to-date
      school.users.each do |user|
        LeadPartnerUser.find_or_create_by!(lead_partner:, user:)
      end

      # Remove any LeadPartnerUser records that no longer correspond to the school's users
      LeadPartnerUser.where(lead_partner:).where.not(user_id: school.user_ids).destroy_all
    end
  end
end
