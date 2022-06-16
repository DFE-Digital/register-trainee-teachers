# frozen_string_literal: true

class AddStartAndEndAcademicCycleToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_reference :trainees, :start_academic_cycle, foreign_key: { to_table: :academic_cycles }
    add_reference :trainees, :end_academic_cycle, foreign_key: { to_table: :academic_cycles }
  end
end
