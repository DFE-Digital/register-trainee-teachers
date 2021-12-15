# frozen_string_literal: true

class ChangeHigherDegreeToHigherDegreeOrEquivalent < ActiveRecord::Migration[6.1]
  def up
    Degree.where(uk_degree: "Higher Degree").update_all(uk_degree: "Higher degree or equivalent")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
