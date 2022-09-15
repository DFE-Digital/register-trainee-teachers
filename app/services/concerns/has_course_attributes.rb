# frozen_string_literal: true

module HasCourseAttributes
  def course_attributes
    attributes = {
      course_education_phase: course_education_phase,
      course_subject_one: course_subject_one_name,
      course_subject_two: course_subject_two_name,
      course_subject_three: course_subject_three_name,
      course_min_age: course_age_range && course_age_range[0],
      course_max_age: course_max_age,
      study_mode: study_mode,
      itt_start_date: itt_start_date,
      itt_end_date: itt_end_date,
      trainee_start_date: trainee_start_date,
      course_allocation_subject: course_allocation_subject,
    }

    primary_education_phase? ? fix_invalid_primary_course_subjects(attributes) : attributes
  end

  def primary_education_phase?
    course_max_age && course_max_age <= AgeRange::UPPER_BOUND_PRIMARY_AGE
  end

  def course_max_age
    course_age_range && course_age_range[1]
  end

  def fix_invalid_primary_course_subjects(course_attributes)
    # This always ensures "primary teaching" is the first subject or inserts it if it's missing
    other_subjects = course_subjects - [CourseSubjects::PRIMARY_TEACHING]
    course_attributes.merge(course_subject_one: CourseSubjects::PRIMARY_TEACHING,
                            course_subject_two: other_subjects.first,
                            course_subject_three: other_subjects.second)
  end

  def course_subjects
    [course_subject_one_name, course_subject_two_name, course_subject_three_name].compact
  end

  def course_allocation_subject
    SubjectSpecialism.find_by(name: course_subject_one_name)&.allocation_subject
  end
end
