# frozen_string_literal: true

module HasCourseAttributes
  include PrimaryCourseSubjects

  def course_attributes
    attributes = {
      course_education_phase:,
      course_subject_one:,
      course_subject_two:,
      course_subject_three:,
      course_min_age:,
      course_max_age:,
      study_mode:,
      itt_start_date:,
      itt_end_date:,
      trainee_start_date:,
      course_allocation_subject:,
    }

    if primary_education_phase? && !attributes.values.include?(HesaMapperConstants::INVALID)
      return attributes.merge(primary_course_subjects)
    end

    attributes
  end

private

  def course_education_phase
    COURSE_EDUCATION_PHASE_ENUMS[:secondary]
  end

  def course_min_age
    course_age_range && course_age_range[0]
  end

  def course_max_age
    course_age_range && course_age_range[1]
  end

  def course_allocation_subject
    return nil if course_subject_one.is_a?(Api::V01::HesaMapper::Attributes::InvalidValue)

    SubjectSpecialism.find_by(name: course_subject_one)&.allocation_subject
  end
end
