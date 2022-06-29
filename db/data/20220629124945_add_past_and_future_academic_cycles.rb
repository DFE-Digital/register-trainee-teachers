# frozen_string_literal: true

class AddPastAndFutureAcademicCycles < ActiveRecord::Migration[6.1]
  def up
    # Past cycles
    2009.upto(2014).each do |year|
      AcademicCycle.create({ start_date: "1/8/#{year}", end_date: "31/7/#{year + 1}" })
    end

    # Future cycle
    AcademicCycle.create(start_date: "01/8/2023", end_date: "31/7/2024")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
