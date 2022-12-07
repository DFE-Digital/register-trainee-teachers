# frozen_string_literal: true

class ImportApplyApplicationsNoLongerSeenAsDuplicates < ActiveRecord::Migration[6.1]
  def up
    ApplyApplication.non_importable_duplicate.each do |application|
      next unless application.provider && application.course

      Trainees::CreateFromApply.call(application:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
