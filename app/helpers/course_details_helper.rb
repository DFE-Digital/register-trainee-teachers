# frozen_string_literal: true

module CourseDetailsHelper
  include ApplicationHelper

  def course_subjects_options
    to_options(course_subjects)
  end

  def filter_course_subjects_options
    to_options(all_subjects, first_value: "All subjects")
  end

  def main_age_ranges_options(level: :primary)
    age_ranges(option: :main, level: level)
  end

  def additional_age_ranges_options(level: :primary)
    to_options(age_ranges(option: :additional, level: level))
  end

  def route_title(route)
    t("views.forms.publish_course_details.route_titles.#{route}")
  end

  def subjects_for_summary_view(subject_one, subject_two, subject_three)
    additional_subjects = [subject_two, subject_three].reject(&:blank?).join(" and ")

    [subject_one&.upcase_first, additional_subjects].reject(&:blank?).join(" with ")
  end

  def format_language(language)
    language =~ /language$/ && !language.include?("English") ? language.gsub(" language", "").chomp : language
  end

  def sort_specialisms(subject, specialisms)
    specialisms.sort { |a, b| a.downcase == subject.downcase ? -1 : a <=> b }
  end

  def sort_languages(languages)
    languages.sort { |a, b| a.include?(AllocationSubjects::MODERN_LANGUAGES.downcase) ? -1 : a <=> b }
  end

private

  def age_ranges(option:, level:)
    Dttp::CodeSets::AgeRanges::MAPPING.select { |_, attributes| attributes[:option] == option && attributes[:levels]&.include?(level.to_sym) }.keys.map do |age_range|
      age_range.join(" to ")
    end
  end

  def course_subjects
    @course_subjects ||= SubjectSpecialism.secondary.order_by_name.pluck(:name)
  end

  def all_subjects
    @all_subjects ||= (SubjectSpecialism.pluck(:name) + AllocationSubject.pluck(:name))
      .map(&:downcase).uniq.sort
  end
end
