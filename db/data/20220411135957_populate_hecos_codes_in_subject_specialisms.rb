# frozen_string_literal: true

class PopulateHecosCodesInSubjectSpecialisms < ActiveRecord::Migration[6.1]
  def up
    SubjectSpecialism.find_each do |subject_specialism|
      subject_specialism.update(
        hecos_code: DegreeSubjects::MAPPING.dig(CourseSubjects::MAPPING[subject_specialism.name], :hecos_code),
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
