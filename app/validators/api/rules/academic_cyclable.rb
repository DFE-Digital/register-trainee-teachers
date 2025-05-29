# frozen_string_literal: true

module Api
  module Rules
    module AcademicCyclable
      extend ActiveSupport::Concern

      def academic_cycle
        @academic_cycle ||= start_date.present? ? AcademicCycle.for_date(start_date) : AcademicCycle.for_date(Time.zone.now + ::Trainees::SetAcademicCycles::DEFAULT_CYCLE_OFFSET)
      end

      def start_date
        value = trainee_attributes.trainee_start_date || trainee_attributes.itt_start_date
        if value.is_a?(String)
          value = valid_date_string?(value) ? Date.iso8601(value) : nil
        end
        value
      end
    end
  end
end
