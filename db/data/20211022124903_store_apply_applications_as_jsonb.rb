# frozen_string_literal: true

class StoreApplyApplicationsAsJsonb < ActiveRecord::Migration[6.1]
  def up
    ApplyApplication.find_each do |application|
      application.update_column(:application, JSON.parse(application.application))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
