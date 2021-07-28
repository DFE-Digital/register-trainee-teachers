# frozen_string_literal: true

class ChangeAppplyApplicationsInvalidData < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:apply_applications, :invalid_data, from: nil, to: {})
  end
end
