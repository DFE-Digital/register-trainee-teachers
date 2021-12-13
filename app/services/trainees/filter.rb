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

    def record_source(trainees, record_source)
      return trainees if record_source.blank? || record_source.size > 1

      return trainees.with_manual_application if record_source.include?("manual")

      trainees.with_apply_application
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

    def trainees_on_science_courses(trainees)
      trainees.with_subject_or_allocation_subject("physics").or(trainees.with_subject_or_allocation_subject("chemistry").or(trainees.with_subject_or_allocation_subject("biology")))
    end

    def text_search(trainees, text_search)
      return trainees if text_search.blank?

      trainees.with_name_trainee_id_or_trn_like(text_search)
    end

    def provider(trainees, provider)
      return trainees if provider.blank?

      trainees.where(provider: provider)
    end

    def submission_ready(trainees, record_completion)
      return trainees if record_completion.blank? || record_completion.size > 1

      trainees.where(submission_ready: record_completion.include?("complete"))
    end

    def trainee_start_year(trainees, start_years)
      return trainees if start_years.blank?

      scoped = nil
      start_years.each do |start_year|
        academic_cycle = AcademicCycle.for_year(start_year)
        if scoped
          scoped = scoped.or(academic_cycle.trainees_starting)
        else
          scoped = academic_cycle.trainees_starting
        end
      end

      trainees.merge(scoped)
    end

    def filter_trainees
      filtered_trainees = trainees

      filtered_trainees = training_route(filtered_trainees, filters[:training_route])
      filtered_trainees = state(filtered_trainees, filters[:state])
      filtered_trainees = subject(filtered_trainees, filters[:subject])
      filtered_trainees = text_search(filtered_trainees, filters[:text_search])
      filtered_trainees = level(filtered_trainees, filters[:level])
      filtered_trainees = provider(filtered_trainees, filters[:provider])
      filtered_trainees = submission_ready(filtered_trainees, filters[:record_completion])
      filtered_trainees = trainee_start_year(filtered_trainees, filters[:trainee_start_year])

      record_source(filtered_trainees, filters[:record_source])
    end
  end
end
