# frozen_string_literal: true

class ResetUpdateSha < ActiveRecord::Migration[6.1]
  def up
    trainees = Trainee.where("updated_at < ?", 1.day.ago).where("updated_at != created_at")
    trainees.each do |t|
      t.update!(dttp_update_sha: t.sha)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
