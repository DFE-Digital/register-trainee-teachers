# frozen_string_literal: true

class AddApplySyncToProvider < ActiveRecord::Migration[6.1]
  def change
    add_column :providers, :apply_sync_enabled, :boolean, default: false
  end
end
