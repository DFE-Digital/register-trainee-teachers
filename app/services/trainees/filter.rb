# frozen_string_literal: true

module Trainees
  class Filter
    include ServicePattern

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

      trainees.with_subject_or_allocation_subject(subject)
    end

    def text_search(trainees, text_search)
      return trainees if text_search.blank?

      trainees.with_name_trainee_id_or_trn_like(text_search)
    end

    def filter_trainees
      # Tech note: If you're adding a new filter to the top of this list, make
      # sure that it acts on `trainees` and all other filters then act on
      # `filtered_trainees`
      filtered_trainees = training_route(trainees, filters[:training_route])
      filtered_trainees = state(filtered_trainees, filters[:state])
      filtered_trainees = subject(filtered_trainees, filters[:subject])
      filtered_trainees = text_search(filtered_trainees, filters[:text_search])
      filtered_trainees = level(filtered_trainees, filters[:level])

      record_source(filtered_trainees, filters[:record_source])
    end
  end
end
