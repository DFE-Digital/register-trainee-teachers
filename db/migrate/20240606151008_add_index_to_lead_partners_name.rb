# frozen_string_literal: true

class AddIndexToLeadPartnersName < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :lead_partners, :name, unique: false, algorithm: :concurrently
  end
end
