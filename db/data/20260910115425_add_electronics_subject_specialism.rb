# frozen_string_literal: true

class AddElectronicsSubjectSpecialism < ActiveRecord::Migration[8.1]
  def up
    allocation_subject = AllocationSubject.find_by!(name: AllocationSubjects::DESIGN_AND_TECHNOLOGY)

    specialism = SubjectSpecialism.find_or_initialize_by(name: CourseSubjects::ELECTRONICS)
    specialism.allocation_subject = allocation_subject
    specialism.hecos_code = nil
    specialism.name = CourseSubjects::ELECTRONICS
    specialism.save!
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
