# frozen_string_literal: true

class TraineeFilter
  AWARD_STATES = %w[qts_recommended qts_awarded eyts_recommended eyts_awarded].freeze
  STATES = Trainee.states.keys.excluding("recommended_for_award", "awarded") + AWARD_STATES

  RECORD_SOURCES = %w[apply manual dttp hesa].freeze

  def initialize(params:)
    @params = params
  end

  def filters
    return if params.empty?

    return if merged_filters.empty?

    merged_filters
  end

private

  attr_reader :params

  def merged_filters
    @merged_filters ||= text_search.merge(
      **level,
      **training_route,
      **state,
      **subject,
      **text_search,
      **record_source,
      **provider,
      **record_completions,
      **start_year,
      **trainee_start_years,
      **study_modes,
    ).with_indifferent_access
  end

  def level
    return {} unless level_options.any?

    { "level" => level_options }
  end

  def level_options
    COURSE_LEVELS.keys.map(&:to_s).each_with_object([]) do |option, arr|
      arr << option if params[:level]&.include?(option)
    end
  end

  def start_year
    academic_cycle ||= AcademicCycle.for_year(params[:start_year])
    return {} unless academic_cycle

    { "start_year" => params[:start_year] }
  end

  def training_route
    return {} unless training_route_options.any?

    { "training_route" => training_route_options }
  end

  def record_source
    return {} unless record_source_options.any?

    { "record_source" => record_source_options }
  end

  def record_source_options
    (params[:record_source].presence || []) & RECORD_SOURCES
  end

  def training_route_options
    Trainee.training_routes.keys.each_with_object([]) do |option, arr|
      arr << option if params[:training_route]&.include?(option)
    end
  end

  def state
    return {} unless state_options.any?

    { "state" => state_options }
  end

  def state_options
    STATES.each_with_object([]) do |option, arr|
      arr << option if params[:state]&.include?(option)
    end
  end

  def subject
    return {} unless params[:subject].present? && params[:subject] != "All subjects"

    { "subject" => params[:subject] }
  end

  def text_search
    return {} if params[:text_search].blank?

    { "text_search" => params[:text_search] }
  end

  def provider
    return {} unless provider_option

    { "provider" => provider_option }
  end

  def provider_option
    @provider_option ||= Provider.find_by(id: params[:provider])
  end

  def record_completions
    return {} unless record_completion_options.any?

    { "record_completion" => record_completion_options }
  end

  def record_completion_options
    %w[complete incomplete].each_with_object([]) do |option, arr|
      arr << option if params[:record_completion]&.include?(option)
    end
  end

  def trainee_start_years
    return {} if params[:trainee_start_year].blank?

    { "trainee_start_year" => params[:trainee_start_year] }
  end

  def study_modes
    return {} unless study_mode_options.any?

    { "study_mode" => study_mode_options }
  end

  def study_mode_options
    %w[full_time part_time].each_with_object([]) do |option, arr|
      arr << option if params[:study_mode]&.include?(option)
    end
  end
end
