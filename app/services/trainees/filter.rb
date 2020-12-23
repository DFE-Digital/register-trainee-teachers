# frozen_string_literal: true

module Trainees
  class Filter
    include ServicePattern

    def initialize(trainees:, filters:)
      @trainees = trainees
      @filters = filters
    end

    def call
      return trainees if filters.empty?

      filter_trainees
    end

  private

    attr_reader :trainees, :filters

    def record_type(trainees, record_type)
      return trainees if record_type.blank?

      trainees.where(record_type: record_type)
    end

    def state(trainees, state)
      return trainees if state.blank?

      trainees.where(state: state)
    end

    def subject(trainees, subject)
      return trainees if subject.blank? || subject == "All subjects"

      trainees.where(subject: subject)
    end

    def filter_trainees
      # Tech note: If you're adding a new filter to the top of this list, make
      # sure that it acts on `trainees` and all other filters then act on
      # `filtered_trainees`
      filtered_trainees = record_type(trainees, filters[:record_type])
      filtered_trainees = state(filtered_trainees, filters[:state])
      filtered_trainees = subject(filtered_trainees, filters[:subject])
      filtered_trainees
    end
  end
end
