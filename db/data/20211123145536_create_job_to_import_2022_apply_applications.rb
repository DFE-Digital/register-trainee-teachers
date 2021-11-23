# frozen_string_literal: true

class CreateJobToImport2022ApplyApplications < ActiveRecord::Migration[6.1]
  def up
    ApplyApi::ImportApplicationsJob.perform_later(from_date: Date.parse("01/09/2021"), recruitment_cycle_years: [2022])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
