# frozen_string_literal: true

class AddMiddleNamesToTrainees < ActiveRecord::Migration[6.0]
  def change
    add_column :trainees, :middle_names, :text
  end
end
