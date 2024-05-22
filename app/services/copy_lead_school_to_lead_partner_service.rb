# frozen_string_literal: true

class CopyLeadSchoolToLeadPartnerService
  def call
    School.lead_only.find_each do |school|
      next if LeadPartner.exists?(urn: school.urn, school_id: school.id)

      LeadPartner.create!(
        name: school.name,
        record_type: LeadPartner::LEAD_SCHOOL,
        urn: school.urn,
        school: school
      )
    end
  end
end