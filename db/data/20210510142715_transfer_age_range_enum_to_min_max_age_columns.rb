# frozen_string_literal: true

class TransferAgeRangeEnumToMinMaxAgeColumns < ActiveRecord::Migration[6.1]
  def up
    # Diplomas are no longer supported - replacing it with a course equivalent for the same age range
    Trainee.where(age_range: 16).update_all(age_range: 14)

    Trainee.all.each do |trainee|
      course_min_age, course_max_age = trainee.age_range
      trainee.update!(course_min_age: course_min_age, course_max_age: course_max_age)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
