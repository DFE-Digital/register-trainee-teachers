# frozen_string_literal: true

class BackfillDegreeUuids < ActiveRecord::Migration[6.1]
  def up
    Degree.uk.find_each do |degree|
      Degree::FixToMatchReferenceData.call(degree: degree)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
