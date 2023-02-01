# frozen_string_literal: true

# == Schema Information
#
# Table name: apply_application_sync_requests
#
#  id                     :bigint           not null, primary key
#  recruitment_cycle_year :integer
#  response_code          :integer
#  successful             :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_apply_application_sync_requests_on_recruitment_cycle_year  (recruitment_cycle_year)
#
class ApplyApplicationSyncRequest < ApplicationRecord
  scope :successful, -> { where(successful: true) }
  scope :unsuccessful, -> { where(successful: false) }
end
