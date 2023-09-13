# frozen_string_literal: true

class UpdateAcademicCycleDates < ActiveRecord::Migration[6.1]
  def up
    AcademicCycle.find_each do |academic_cycle|
      academic_cycle.start_date = Date.new(academic_cycle.start_date.year, 8, 1)
      academic_cycle.end_date = Date.new(academic_cycle.end_date.year, 7, 31)
      academic_cycle.save!
    end
  end

  def down
    AcademicCycle.find_each do |academic_cycle|
      academic_cycle.start_date = Date.new(academic_cycle.start_date.year, 9, 1)
      academic_cycle.end_date = Date.new(academic_cycle.end_date.year, 8, 31)
      academic_cycle.save!
    end
  end
end
