# frozen_string_literal: true

class AddAcademicCycleConstraint < ActiveRecord::Migration[6.1]
  def up
    # Add constraint date range for the start date and end date of the academic cycle
    enable_extension "btree_gist" unless extension_enabled?("btree_gist")

    execute <<-SQL
      ALTER TABLE academic_cycles
        ADD CONSTRAINT academic_cycles_date_range
        EXCLUDE USING GIST (
          tsrange(start_date, end_date) WITH &&
        );
    SQL
  end

  def down
    disable_extension "btree_gist"

    execute <<-SQL
      ALTER TABLE academic_cycles
        DROP CONSTRAINT academic_cycles_date_range
    SQL
  end
end
