# frozen_string_literal: true

class UpdateDttpForEbaccTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.where(ebacc: true).each do |trainee|
      Dttp::UpdateTraineeJob.perform_later(trainee)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
