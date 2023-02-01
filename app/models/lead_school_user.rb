# frozen_string_literal: true

# == Schema Information
#
# Table name: lead_school_users
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lead_school_id :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_lead_school_users_on_lead_school_id  (lead_school_id)
#  index_lead_school_users_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (lead_school_id => schools.id)
#  fk_rails_...  (user_id => users.id)
#
class LeadSchoolUser < ApplicationRecord
  belongs_to :lead_school, -> { lead_only }, class_name: "School", inverse_of: :lead_school_users
  belongs_to :user
end
