# frozen_string_literal: true

class AddSystemAdminBooleanToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :system_admin, :boolean, default: false
    change_column_null :users, :provider_id, true
  end
end
