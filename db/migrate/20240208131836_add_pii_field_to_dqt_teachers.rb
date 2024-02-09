# frozen_string_literal: true

class AddPiiFieldToDqtTeachers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :dqt_teachers, :allowed_pii_updates, :boolean, default: false, null: false
    add_index :dqt_teachers, :allowed_pii_updates, algorithm: :concurrently
  end
end
