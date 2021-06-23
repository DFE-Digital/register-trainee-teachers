# frozen_string_literal: true

class CalculateSubjectSpecialisms
  include ServicePattern

  MAX_SUBJECTS_ALLOWED = 3

  def initialize(subjects:)
    @subjects = subjects
  end

  def call
    return attributes_for_language_subject if all_subjects_are_language?
    return attributes_for_primary_subject if primary_subject?
    return attributes_for_single_subject if single_subject?

    attributes_for_multiple_subjects
  end

private

  attr_accessor :subjects

  def attributes_for_language_subject
    specialisms = subjects.flat_map { |subject| lookup_subject_specialism(subject) }

    {
      course_subject_one: specialisms, course_subject_two: [], course_subject_three: []
    }
  end

  def attributes_for_single_subject
    {
      course_subject_one: lookup_subject_specialism(subjects.first), course_subject_two: [], course_subject_three: []
    }
  end

  def attributes_for_primary_subject
    specialisms = lookup_subject_specialism(subjects.first)

    {
      course_subject_one: [specialisms.first].compact,
      course_subject_two: [specialisms.second].compact,
      course_subject_three: [specialisms.third].compact,
    }
  end

  def attributes_for_multiple_subjects
    first_subject, second_subject, third_subject = subjects.first(MAX_SUBJECTS_ALLOWED)

    {
      course_subject_one: lookup_subject_specialism(first_subject),
      course_subject_two: lookup_subject_specialism(second_subject),
      course_subject_three: lookup_subject_specialism(third_subject),
    }
  end

  def single_subject?
    subjects.size == 1
  end

  def primary_subject?
    single_subject? && subjects.first.include?(Dttp::CodeSets::AllocationSubjects::PRIMARY)
  end

  def all_subjects_are_language?
    subjects.all? { |subject| PUBLISH_LANGUAGE_SUBJECTS.include?(subject) }
  end

  def lookup_subject_specialism(subject)
    PUBLISH_SUBJECT_SPECIALISM_MAPPING.fetch(subject, [])
  end
end
