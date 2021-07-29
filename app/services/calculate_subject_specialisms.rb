# frozen_string_literal: true

class CalculateSubjectSpecialisms
  include ServicePattern

  MAX_SUBJECTS_ALLOWED = 3

  def initialize(subjects:)
    @subjects = subjects
  end

  def call
    case specialism_type
    when :language
      attributes_for_language_subject
    when :primary
      attributes_for_primary_subject
    when :single
      attributes_for_single_subject
    else
      attributes_for_multiple_subjects
    end
  end

private

  attr_reader :subjects

  def specialism_type
    @specialism_type ||= CalculateSubjectSpecialismType.call(subjects: subjects)
  end

  def attributes_for_language_subject
    specialisms = modern_language_filter(subjects).flat_map { |subject| lookup_subject_specialism(subject) }

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

  def lookup_subject_specialism(subject)
    PUBLISH_SUBJECT_SPECIALISM_MAPPING.fetch(subject, [])
  end

  def modern_language_filter(subjects)
    # We want to avoid 2 scenarios when a course has more than one language and one of those subjects is
    # "Modern Languages" or "Modern languages (other)".
    #
    # Scenario 1:
    #   A language course has 2 subjects for example: "German" and "Modern languages (other)". We don't
    #   care about "Modern languages (other)" so we need to get rid of it.
    #
    # Scenario 2:
    #   A language course has several subjects including "Modern Languages" or "Modern languages (other)".
    #   If the method above "attributes_for_language_subject" attempts to lookup the specialisms for
    #   modern languages, it will get all the languages which doesn't add any value. The provider is
    #   going to have to choose the languages anyway.
    subjects.size > 1 ? subjects.reject { |s| s.downcase.include?("modern") } : subjects
  end
end
