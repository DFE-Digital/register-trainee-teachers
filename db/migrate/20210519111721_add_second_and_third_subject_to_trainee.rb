# frozen_string_literal: true

class AddSecondAndThirdSubjectToTrainee < ActiveRecord::Migration[6.1]
  def change
    change_table :trainees, bulk: true do |t|
      t.text :subject_two
      t.text :subject_three
    end
  end
end
