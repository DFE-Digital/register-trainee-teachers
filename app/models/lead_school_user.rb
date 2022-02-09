# frozen_string_literal: true

class LeadSchoolUser < ApplicationRecord
  belongs_to :lead_school, -> { lead_only }, class_name: "School", inverse_of: :lead_school_users
  belongs_to :user
end
