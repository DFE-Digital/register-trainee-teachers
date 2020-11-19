# frozen_string_literal: true

class RemoveNationalityFromTrainees < ActiveRecord::Migration[6.0]
  def change
    remove_column :trainees, :nationality, :text
  end
end
