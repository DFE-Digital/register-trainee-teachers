# frozen_string_literal: true

class LeadSchoolUser < ApplicationRecord
  belongs_to :lead_school, -> { where(lead_school: true) }, class_name: "School", inverse_of: :lead_school_users
  belongs_to :user
end
