# frozen_string_literal: true

module Trainees
  class Filter
    include ServicePattern
    ALL_SCIENCES_FILTER = "Sciences - biology, chemistry, physics"

    def initialize(trainees:, filters:)
      @trainees = remove_empty_trainees(trainees)
      @filters = filters
    end

    def call
      return trainees unless filters

      filter_trainees
    end

  private

    attr_reader :trainees, :filters

    def remove_empty_trainees(trainees)
      trainees.where.not(id: FindEmptyTrainees.call(trainees: trainees, ids_only: true))
    end

    def level(trainees, levels)
      return trainees if levels.blank?

      trainees.with_education_phase(*levels)
    end

    def record_source(trainees, record_source_values)
      scope_map = {
        "dttp" => :created_from_dttp,
        "manual" => :with_manual_application,
        "apply" => :with_apply_application,
        "hesa" => :imported_from_hesa,
      }
      scoped_trainees = trainees

      Array(record_source_values).each_with_index do |source, i|
        scope_name = scope_map[source]

        if i.zero?
          scoped_trainees = scoped_trainees.send(scope_name)
        else
          scoped_trainees = scoped_trainees.or(trainees.send(scope_name))
        end
      end

      scoped_trainees
    end

    def training_route(trainees, training_route)
      return trainees if training_route.blank?

      trainees.where(training_route: training_route)
    end

    def state(trainees, states)
      return trainees if states.blank?

      non_award_states = states.dup

      award_states = []
      states.each do |state|
        award_states << non_award_states.delete(state) if TraineeFilter::AWARD_STATES.include?(state)
      end

      trainees.where(state: non_award_states).or(trainees.with_award_states(*award_states))
    end

    def subject(trainees, subject)
      return trainees if subject.blank?

      if subject == ALL_SCIENCES_FILTER
        return trainees_on_science_courses(trainees)
      end

      trainees.with_subject_or_allocation_subject(subject)
    end

    def start_year(trainees, cycle_start_year)
      return trainees if cycle_start_year.blank?

      academic_cycle_scope = AcademicCycle.for_year(cycle_start_year).trainees_starting

      trainees.merge(academic_cycle_scope)
    end

    def end_year(trainees, cycle_start_year)
      return trainees if cycle_start_year.blank?

      academic_cycle_scope = AcademicCycle.for_year(cycle_start_year).trainees_ending

      trainees.merge(academic_cycle_scope)
    end

    def trainees_on_science_courses(trainees)
      trainees.with_subject_or_allocation_subject(AllocationSubjects::PHYSICS.downcase)
              .or(trainees.with_subject_or_allocation_subject(AllocationSubjects::CHEMISTRY.downcase)
              .or(trainees.with_subject_or_allocation_subject(AllocationSubjects::BIOLOGY.downcase))
              .or(trainees.with_subject_or_allocation_subject(AllocationSubjects::GENERAL_SCIENCES.downcase)))
    end

    def text_search(trainees, text_search)
      return trainees if text_search.blank?

      trainees.with_name_trainee_id_or_trn_like(text_search)
    end

    def provider(trainees, provider)
      return trainees if provider.blank?

      trainees.where(provider: provider)
    end

    def record_completion(trainees, record_completion)
      return trainees if record_completion.blank? || record_completion.size > 1

      if record_completion.include?("complete")
        trainees.complete_for_filter
      else
        trainees.incomplete_for_filter
      end
    end

    def study_mode(trainees, study_mode)
      return trainees if study_mode.blank? || (study_mode.count == 2)

      if study_mode.count == 1
        trainees.where(study_mode: study_mode).where.not(training_route: "assessment_only").where.not(training_route: "early_years_assessment_only")
      end
    end

    def filter_trainees
      filtered_trainees = trainees

      filtered_trainees = training_route(filtered_trainees, filters[:training_route])
      filtered_trainees = state(filtered_trainees, filters[:state])
      filtered_trainees = subject(filtered_trainees, filters[:subject])
      filtered_trainees = start_year(filtered_trainees, filters[:start_year])
      filtered_trainees = end_year(filtered_trainees, filters[:end_year])
      filtered_trainees = text_search(filtered_trainees, filters[:text_search])
      filtered_trainees = level(filtered_trainees, filters[:level])
      filtered_trainees = provider(filtered_trainees, filters[:provider])
      filtered_trainees = record_completion(filtered_trainees, filters[:record_completion])
      filtered_trainees = study_mode(filtered_trainees, filters[:study_mode])

      record_source(filtered_trainees, filters[:record_source])
    end
  end
end
