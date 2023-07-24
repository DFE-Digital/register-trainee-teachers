# frozen_string_literal: true

class BackfillHesaStudentInstanceIds < ActiveRecord::Migration[7.0]
  def up
    return unless Rails.env.production?

    Hesa::SyncStudentsJob.perform_later(upload_id: 11)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
