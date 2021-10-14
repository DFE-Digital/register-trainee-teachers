# frozen_string_literal: true

class AddCourseUuidsToTrainees < ActiveRecord::Migration[6.1]
  def up
    trainees_with_missing_uuid = Trainee.where.not(course_code: nil).where(course_uuid: nil)
    course_code_to_uuid = Course.all.pluck(:code, :uuid).to_h

    trainees_with_missing_uuid.find_each(batch_size: 500) do |trainee|
      trainee.update(course_uuid: course_code_to_uuid[trainee.course_code])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
