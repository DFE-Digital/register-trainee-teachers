# frozen_string_literal: true

class AddUuidColumnsToDegrees < ActiveRecord::Migration[6.1]
  def change
    change_table :degrees, bulk: true do |t|
      t.uuid :uk_degree_uuid
      t.uuid :subject_uuid
      t.uuid :grade_uuid
    end
  end
end
