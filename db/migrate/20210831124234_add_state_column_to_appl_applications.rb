# frozen_string_literal: true

class AddStateColumnToApplApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :apply_applications, :state, :integer
  end
end
