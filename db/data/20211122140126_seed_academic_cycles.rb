# frozen_string_literal: true

class SeedAcademicCycles < ActiveRecord::Migration[6.1]
  def up
    ACADEMIC_CYCLES.each do |academic_cycle|
      AcademicCycle.find_or_create_by!(start_date: academic_cycle[:start_date], end_date: academic_cycle[:end_date])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
