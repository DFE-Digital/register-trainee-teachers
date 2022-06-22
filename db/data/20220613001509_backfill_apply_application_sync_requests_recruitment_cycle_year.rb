# frozen_string_literal: true

class BackfillApplyApplicationSyncRequestsRecruitmentCycleYear < ActiveRecord::Migration[6.1]
  def up
    ApplyApplicationSyncRequest.update_all(recruitment_cycle_year: 2021)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
