# frozen_string_literal: true

class ChangeGenderToSex < ActiveRecord::Migration[6.1]
  def change
    rename_column(:trainees, :gender, :sex)
    rename_column(:hesa_students, :gender, :sex)
  end
end
