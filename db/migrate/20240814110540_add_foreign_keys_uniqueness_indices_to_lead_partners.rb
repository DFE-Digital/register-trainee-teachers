# frozen_string_literal: true

class AddForeignKeysUniquenessIndicesToLeadPartners < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    remove_index :lead_partners, :school_id if index_exists?(:lead_partners, :school_id)
    remove_index :lead_partners, :provider_id if index_exists?(:lead_partners, :provider_id)

    add_index :lead_partners, :school_id, unique: true, algorithm: :concurrently
    add_index :lead_partners, :provider_id, unique: true, algorithm: :concurrently
  end

  def down
    remove_index :lead_partners, :school_id, unique: true if index_exists?(:lead_partners, :school_id)
    remove_index :lead_partners, :provider_id, unique: true if index_exists?(:lead_partners, :provider_id)

    add_index :lead_partners, :school_id, algorithm: :concurrently
    add_index :lead_partners, :provider_id, algorithm: :concurrently
  end
end
