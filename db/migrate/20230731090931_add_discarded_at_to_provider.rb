# frozen_string_literal: true

class AddDiscardedAtToProvider < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :providers, :discarded_at, :datetime
    add_index :providers, :discarded_at, algorithm: :concurrently
  end
end
