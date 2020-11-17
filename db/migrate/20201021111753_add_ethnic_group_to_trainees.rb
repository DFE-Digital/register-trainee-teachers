# frozen_string_literal: true

class AddEthnicGroupToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :ethnic_group, :integer
    add_index :trainees, :ethnic_group
  end
end
