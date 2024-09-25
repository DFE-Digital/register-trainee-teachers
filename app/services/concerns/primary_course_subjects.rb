# frozen_string_literal: true

module PrimaryCourseSubjects
  extend ActiveSupport::Concern

  def primary_course_subjects(_attributes)
    # This always ensures "primary teaching" is the first subject or inserts it if it's missing
    other_subjects = course_subjects - [CourseSubjects::PRIMARY_TEACHING]

    {
      course_education_phase: COURSE_EDUCATION_PHASE_ENUMS[:primary],
      course_subject_one: CourseSubjects::PRIMARY_TEACHING,
      course_subject_two: other_subjects.first,
      course_subject_three: other_subjects.second,
    }
  end

private

  def primary_education_phase?
    course_max_age && course_max_age <= DfE::ReferenceData::AgeRanges::UPPER_BOUND_PRIMARY_AGE
  end

  def course_subjects
    [course_subject_one, course_subject_two, course_subject_three].compact
  end
end
