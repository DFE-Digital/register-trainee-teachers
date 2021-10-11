# frozen_string_literal: true

class BackfillTraineeCourseUuids < ActiveRecord::Migration[6.1]
  def up
    Trainee.where.not(course_code: nil).find_each do |trainee|
      if (course = trainee.published_course) # double check course exists just in case
        trainee.update(course_uuid: course.uuid)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
