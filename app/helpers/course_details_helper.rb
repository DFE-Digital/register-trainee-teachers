# frozen_string_literal: true

module CourseDetailsHelper
  include ApplicationHelper

  def course_subjects_options
    to_options(course_subjects)
  end

  def filter_course_subjects_options
    to_options(all_subjects, first_value: "All subjects")
  end

  def filter_year_options(current_user, cycle_context)
    to_options(year_filter_options(current_user, cycle_context), first_value: "All years")
  end

  def main_age_ranges_options(level: :primary)
    age_ranges(option: :main, level: level)
  end

  def additional_age_ranges_options(level: :primary)
    to_options(age_ranges(option: :additional, level: level))
  end

  def course_education_phase_checkbox_values
    [COURSE_EDUCATION_PHASE_ENUMS[:primary], COURSE_EDUCATION_PHASE_ENUMS[:secondary]]
  end

  def route_title(route)
    t("views.forms.publish_course_details.route_titles.#{route}")
  end

  def subjects_for_summary_view(subject_one, subject_two, subject_three)
    primary_subjects = PUBLISH_PRIMARY_SUBJECT_SPECIALISM_MAPPING.key([subject_one, subject_two, subject_three].compact_blank)

    return primary_subjects if primary_subjects.present?

    subject_one = PublishSubjects::PRIMARY if subject_one.eql?(CourseSubjects::PRIMARY_TEACHING)

    additional_subjects = [subject_two, subject_three].compact_blank.join(" and ")

    [subject_one&.upcase_first, additional_subjects].compact_blank.join(" with ")
  end

  def format_language(language)
    language =~ /language$/ && language.exclude?("English") ? language.gsub(" language", "").chomp : language
  end

  def sort_specialisms(subject, specialisms)
    specialisms.sort { |a, b| a.downcase == subject.downcase ? -1 : a <=> b }
  end

  def sort_languages(languages)
    languages.sort { |a, b| a.include?(AllocationSubjects::MODERN_LANGUAGES.downcase) ? -1 : a <=> b }
  end

  def path_for_course_details(trainee)
    return edit_trainee_apply_applications_course_details_path(trainee) if trainee.apply_application?

    return edit_trainee_course_details_path(trainee) if trainee.early_years_route?

    edit_trainee_course_education_phase_path(trainee)
  end

  def language_specialism_options
    options = language_specialisms.map do |language|
      [format_language(language).upcase_first, language]
    end

    [["", ""]] + options
  end

  def provider_options(providers)
    providers.map do |provider|
      [
        provider.name_and_code,
        provider.id,
        {
          "data-append": "<p class=\"govuk-!-margin-0 autocomplete__option--hint\">UKPRN: #{provider.ukprn}</p>",
          "data-synonyms": [provider.ukprn, provider.code].join("|"),
        },
      ]
    end
  end

private

  def language_specialisms
    PUBLISH_SUBJECT_SPECIALISM_MAPPING[PublishSubjects::MODERN_LANGUAGES]
  end

  def age_ranges(option:, level:)
    age_ranges = DfE::ReferenceData::AgeRanges::AGE_RANGES.all_as_hash
    age_ranges.select { |_, attributes| attributes[:option] == option && attributes[:levels]&.include?(level&.to_sym) }.keys.map do |age_range|
      age_range.join(" to ")
    end
  end

  def course_subjects
    @course_subjects ||= SubjectSpecialism.secondary.order_by_name.pluck(:name)
  end

  def all_subjects
    @all_subjects ||= (SubjectSpecialism.pluck(:name) + AllocationSubject.pluck(:name) + [Trainees::Filter::ALL_SCIENCES_FILTER]).uniq(&:downcase).sort_by(&:downcase)
  end

  def year_filter_options(current_user, cycle_context)
    AcademicYearFilterOptions.new(user: current_user, draft: draft_records_view?).formatted_years(cycle_context)
  end

  def draft_records_view?
    request.path.match?(/\/drafts/)
  end
end
