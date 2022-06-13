# frozen_string_literal: true

class AddRecruitmentCycleYearToApplyApplicationSyncRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :apply_application_sync_requests, :recruitment_cycle_year, :integer
    add_index :apply_application_sync_requests, :recruitment_cycle_year
  end
end
