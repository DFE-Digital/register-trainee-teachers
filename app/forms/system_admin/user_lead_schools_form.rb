# frozen_string_literal: true

module SystemAdmin
  class UserLeadSchoolsForm
    include ActiveModel::Model

    validates :lead_school_id, presence: true

    attr_accessor :lead_school_id, :user

    def save!
      if valid?
        LeadSchoolUser.find_or_create_by!(lead_school: lead_school, user: user)
      else
        false
      end
    end

  private

    def lead_school
      School.find_by(id: lead_school_id)
    end
  end
end
