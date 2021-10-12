# frozen_string_literal: true

class FixApplyTraineeTrainingRoutes < ActiveRecord::Migration[6.1]
  def up
    Trainee.with_apply_application.where.not(course_code: nil).each do |trainee|
      if trainee.training_route != trainee.published_course.route
        trainee.update(training_route: trainee.published_course.route)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
