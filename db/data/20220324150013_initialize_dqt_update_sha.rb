# frozen_string_literal: true

class InitializeDqtUpdateSha < ActiveRecord::Migration[6.1]
  def up
    Trainee.find_each do |trainee|
      trainee.update(dqt_update_sha: trainee.sha)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
