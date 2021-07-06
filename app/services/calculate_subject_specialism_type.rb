# frozen_string_literal: true

class CalculateSubjectSpecialismType
  include ServicePattern

  def initialize(subjects:)
    @subjects = subjects
  end

  def call
    return :language if all_subjects_are_language?
    return :primary if primary_subject?
    return :single_subject if single_subject?
    return :multuple_subjects
  end

  private

  attr_reader :subjects

  def single_subject?
    subjects.size == 1
  end

  def primary_subject?
    single_subject? && subjects.first.include?(Dttp::CodeSets::AllocationSubjects::PRIMARY)
  end

  def all_subjects_are_language?
    subjects.all? { |subject| PUBLISH_LANGUAGE_SUBJECTS.include?(subject) }
  end
end
