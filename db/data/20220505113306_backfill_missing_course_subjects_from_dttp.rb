# frozen_string_literal: true

class BackfillMissingCourseSubjectsFromDttp < ActiveRecord::Migration[6.1]
  def up
    # Currently, there are ~800 of these in production
    trainees = Trainee.where(created_from_dttp: true, course_subject_one: nil)

    trainees.each { |trainee| fix_course_subject(trainee) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def fix_course_subject(trainee)
    course_subject_dttp_id = trainee.dttp_trainee.latest_placement_assignment.response["_dfe_ittsubject1id_value"]

    mapping = Dttp::CodeSets::CourseSubjects::INACTIVE_MAPPING.select do |_, value|
      value[:entity_id] == course_subject_dttp_id
    end

    return if mapping.none?

    trainee.update(course_subject_one: mapping.keys.first)

    if mapping.values.first[:original_name]
      trainee.update(
        additional_dttp_data: {
          course_subject_one: mapping.values.first[:original_name],
        },
      )
    end
  end
end
