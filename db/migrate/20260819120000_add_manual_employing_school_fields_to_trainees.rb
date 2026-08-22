# frozen_string_literal: true

class AddManualEmployingSchoolFieldsToTrainees < ActiveRecord::Migration[8.0]
  def change
    add_column :trainees, :employing_school_name, :string
    add_column :trainees, :employing_school_urn, :string
    add_column :trainees, :employing_school_postcode, :string
  end
end
