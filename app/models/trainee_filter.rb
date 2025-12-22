# frozen_string_literal: true

class TraineeFilter
  AWARD_STATES = %w[qts_recommended qts_awarded eyts_recommended eyts_awarded].freeze
  STATUSES = %w[course_not_yet_started in_training deferred awarded withdrawn].freeze

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
      **academic_year,
      **level,
      **training_route,
      **status,
      **subject,
      **record_source,
      **provider,
      **record_completions,
      **start_year,
      **end_year,
      **trainee_start_years,
      **study_modes,
      **trn,
    ).with_indifferent_access
  end

  def trn
    return {} if params[:has_trn].blank?

    { "has_trn" => params[:has_trn] == "true" }
  end

  def academic_year
    return {} unless academic_year_options.any?

    { "academic_year" => academic_year_options }
  end

  def current_academic_cycle
    @current_academic_cycle ||= AcademicCycle.current
  end

  def current_start_year
    @current_start_year ||= current_academic_cycle.start_year.to_s
  end

  def previous_start_year
    @previous_start_year ||= (current_academic_cycle.start_year - 1).to_s
  end

  def academic_year_options
    return [] if current_academic_cycle.nil?

    [current_start_year, previous_start_year].each_with_object([]) do |option, arr|
      arr << option if params[:academic_year]&.include?(option)
    end
  end

  def level
    return {} unless level_options.any?

    { "level" => level_options }
  end

  def level_options
    DfE::ReferenceData::AgeRanges::COURSE_LEVELS.keys.map(&:to_s).each_with_object([]) do |option, arr|
      arr << option if params[:level]&.include?(option)
    end
  end

  def start_year
    academic_cycle ||= AcademicCycle.for_year(params[:start_year])

    return {} unless academic_cycle

    { "start_year" => params[:start_year] }
  end

  def end_year
    academic_cycle ||= AcademicCycle.for_year(params[:end_year])

    return {} unless academic_cycle

    { "end_year" => params[:end_year] }
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

  def status
    return {} unless status_options.any?

    { "status" => status_options }
  end

  def status_options
    STATUSES.each_with_object([]) do |option, arr|
      arr << option if params[:status]&.include?(option)
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
    return @provider_option if defined?(@provider_option)

    @provider_option = Provider.find_by(id: params[:provider])
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
