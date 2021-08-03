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
    modern_languages_only? || all_subjects_are_language?
  end

  def primary_subject?
    single_subject? && subjects.first.include?(AllocationSubjects::PRIMARY)
  end

  def modern_languages_only?
    # This is will cover cases where subject is "Modern Languages" or "Modern languages (other)"
    single_subject? && subjects.first.downcase.include?("modern")
  end

  def all_subjects_are_language?
    subjects.all? { |subject| PUBLISH_LANGUAGES.include?(subject) }
  end

  def single_subject?
    subjects.size == 1
  end
end
