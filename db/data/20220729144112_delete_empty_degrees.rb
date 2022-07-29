# frozen_string_literal: true

class DeleteEmptyDegrees < ActiveRecord::Migration[6.1]
  def up
    degrees = Degree.where(
      grade: "Other",
      other_grade: nil,
      uk_degree: nil,
      non_uk_degree: nil,
      subject: nil,
      institution: nil,
      graduation_year: nil,
    )

    degrees.destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
