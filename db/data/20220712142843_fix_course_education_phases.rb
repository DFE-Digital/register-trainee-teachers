# frozen_string_literal: true

class FixCourseEducationPhases < ActiveRecord::Migration[6.1]
  def up
    upper_bound_age = 11

    primary_enum = COURSE_EDUCATION_PHASE_ENUMS[:primary]
    secondary_enum = COURSE_EDUCATION_PHASE_ENUMS[:secondary]

    trainees = Trainee.where.not(training_route: EARLY_YEARS_ROUTES).imported_from_hesa

    secondary_trainees_with_primary_age_age = trainees.where(course_education_phase: secondary_enum)
                                                      .where("course_max_age <= ?", upper_bound_age)

    trainees_with_primary_teaching_subject_only = secondary_trainees_with_primary_age_age.where(
      course_subject_one: CourseSubjects::PRIMARY_TEACHING,
    ).or(secondary_trainees_with_primary_age_age.where(course_subject_two: CourseSubjects::PRIMARY_TEACHING))

    # Move "primary teaching" to course_subject_one
    secondary_trainees_with_primary_age_age.where(course_subject_two: CourseSubjects::PRIMARY_TEACHING).each do |trainee|
      trainee.update_columns(course_subject_one: trainee.course_subject_one, course_subject_two: trainee.course_subject_two)
    end

    # Fix the course_education_phase
    trainees_with_primary_teaching_subject_only.update_all(course_education_phase: primary_enum)

    # We also need to add "primary teaching" to a select number of trainees where the provider has 5 or more cases.
    # Providers with less than 5 will be contacted to see if the data is incorrect.
    trainees_without_primary_subject = secondary_trainees_with_primary_age_age.where.not(id: trainees_with_primary_teaching_subject_only.pluck(:id))

    results = trainees_without_primary_subject.map { |t| t.provider.id }.tally.select { |_, count| count >= 5 }

    trainees_without_primary_subject.where(provider_id: results.keys).each do |trainee|
      trainee.update_columns(course_subject_one: CourseSubjects::PRIMARY_TEACHING,
                             course_subject_two: trainee.course_subject_one,
                             course_education_phase: primary_enum)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
