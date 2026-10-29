# frozen_string_literal: true

class AddReferenceAndFundingMethodToFundingMethods < ActiveRecord::Migration[8.1]
  def up
    add_column :funding_methods, :reference_number, :integer
    add_column :funding_methods, :funding_method, :string

    # Backfill a per-cycle sequence (the IFR number) for existing records,
    # assigned in id order so early records keep the low numbers.
    safety_assured do
      say_with_time "Backfilling funding_methods.reference_number per cycle" do
        execute(<<~SQL)
          UPDATE funding_methods fm
          SET reference_number = seq.rn
          FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY academic_cycle_id ORDER BY id) AS rn
            FROM funding_methods
          ) seq
          WHERE fm.id = seq.id
        SQL
      end
    end

    safety_assured do
      add_index :funding_methods, %i[academic_cycle_id reference_number], unique: true
    end
  end

  def down
    remove_index :funding_methods, %i[academic_cycle_id reference_number]
    remove_column :funding_methods, :funding_method
    remove_column :funding_methods, :reference_number
  end
end
