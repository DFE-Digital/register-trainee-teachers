# frozen_string_literal: true

class AddDiscardedAtToLeadPartners < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :lead_partners, :discarded_at, :datetime
    add_index :lead_partners, :discarded_at, algorithm: :concurrently
  end
end
