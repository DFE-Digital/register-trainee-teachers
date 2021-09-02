# frozen_string_literal: true

class ReplaceProviderIdWithProviderCodeInApplyApplications < ActiveRecord::Migration[6.1]
  def up
    remove_belongs_to :apply_applications, :provider
    add_column :apply_applications, :provider_code, :string
    add_index :apply_applications, :provider_code
  end

  def down
    raise ActiveRecord::IrreversibleMigration # Because we removed a foreign key column
  end
end
