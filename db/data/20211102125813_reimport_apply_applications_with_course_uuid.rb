# frozen_string_literal: true

class ReimportApplyApplicationsWithCourseUuid < ActiveRecord::Migration[6.1]
  def up
    ApplyApi::ImportApplicationsJob.perform_later(from_date: Time.zone.parse("09 Dec 2020 14:00"))
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
