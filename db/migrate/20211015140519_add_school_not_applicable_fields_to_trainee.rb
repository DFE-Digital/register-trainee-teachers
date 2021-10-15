# frozen_string_literal: true

class AddSchoolNotApplicableFieldsToTrainee < ActiveRecord::Migration[6.1]
  def change
    change_table :trainees, bulk: true do |t|
      t.column :lead_school_not_applicable, :boolean, default: false
      t.column :employing_school_not_applicable, :boolean, default: false
    end
  end
end
