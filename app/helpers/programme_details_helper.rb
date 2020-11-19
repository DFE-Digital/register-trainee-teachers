# frozen_string_literal: true

module ProgrammeDetailsHelper
  include ApplicationHelper

  def programme_subjects_options
    to_options(programme_subjects)
  end

  def main_age_ranges_options
    age_ranges(options: :main)
  end

  def additional_age_ranges_options
    to_options(age_ranges(options: :additional))
  end

private

  def age_ranges(options:)
    AGE_RANGES.select { |age_range| age_range[:option] == options }
      .map { |s| s.values[0] }
  end

  def programme_subjects
    PROGRAMME_SUBJECTS.map { |s| s.values[0] }
  end
end
