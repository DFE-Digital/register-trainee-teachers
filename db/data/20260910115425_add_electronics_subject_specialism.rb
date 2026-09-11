# frozen_string_literal: true

class AddElectronicsSubjectSpecialism < ActiveRecord::Migration[8.1]
  def up
    allocation_subject = AllocationSubject.find_by!(name: AllocationSubjects::DESIGN_AND_TECHNOLOGY)

    SubjectSpecialism.find_or_create_by!(name: CourseSubjects::ELECTRONICS) do |ss|
      ss.allocation_subject = allocation_subject
      ss.hecos_code = nil
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
