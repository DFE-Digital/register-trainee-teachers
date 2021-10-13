# frozen_string_literal: true

class AddUuidsToApplications < ActiveRecord::Migration[6.1]
  def up
    ApplyApi::ImportApplicationsJob.perform_later(from_date: Time.zone.parse("24 Sep 2021 12:19:59"))
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
