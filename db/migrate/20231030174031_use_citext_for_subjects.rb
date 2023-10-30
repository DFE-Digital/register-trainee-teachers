class UseCitextForSubjects < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    safety_assured do
      # allocation_subjects
      remove_index :allocation_subjects, name: 'index_allocation_subjects_on_name', algorithm: :concurrently
      change_column :allocation_subjects, :name, :citext
      add_index :allocation_subjects, :name, unique: true, algorithm: :concurrently

      # subject_specialisms
      remove_index :subject_specialisms, name: 'index_subject_specialisms_on_lower_name', algorithm: :concurrently
      change_column :subject_specialisms, :name, :citext
      add_index :subject_specialisms, :name, unique: true, algorithm: :concurrently
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
