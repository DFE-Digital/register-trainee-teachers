# frozen_string_literal: true

class CalculateSubjectSpecialismType
  include ServicePattern

  def initialize(subjects:)
    @subjects = subjects
  end

  def call
    return :primary if primary_subject?
    return :language if language_specialism?
    return :single if single_subject?

    :multiple_subjects
  end

private

  attr_reader :subjects

  def language_specialism?
    subject_is_modern_languages? || all_subjects_are_modern_languages?
  end

  def primary_subject?
    single_subject? && subjects.first.include?(AllocationSubjects::PRIMARY)
  end

  def subject_is_modern_languages?
    # This is will cover cases where subject is "Modern Languages" or "Modern languages (other)"
    single_subject? && subjects.first.downcase.include?("modern")
  end

  def all_subjects_are_modern_languages?
    subjects.all? { |subject| PUBLISH_MODERN_LANGUAGES.include?(subject) }
  end

  def single_subject?
    subjects.size == 1
  end
end
