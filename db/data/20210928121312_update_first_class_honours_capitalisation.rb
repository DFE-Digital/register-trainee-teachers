# frozen_string_literal: true

class UpdateFirstClassHonoursCapitalisation < ActiveRecord::Migration[6.1]
  def up
    Degree.where(grade: "First-class Honours").update_all(grade: Dttp::CodeSets::Grades::FIRST_CLASS_HONOURS)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
