class LeadSchoolUser < ApplicationRecord
  belongs_to :user
  belongs_to :lead_school, class_name: "School"
end
