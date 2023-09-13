# frozen_string_literal: true

class UpdateSchoolsSearchableFieldWithNormalisedName < ActiveRecord::Migration[6.1]
  def up
    School.all.find_each(&:save)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
