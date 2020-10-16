module Trainees
  module Progress
    class PersonalDetails
      attr_reader :status, :trainee

      STATUSES = {
        not_started: "not started",
        in_progress: "in progress",
        completed: "completed",
      }.freeze

      class << self
        def call(**args)
          new(**args).call
        end
      end

      def initialize(trainee:)
        @trainee = trainee
        @validator = PersonalDetail.new(trainee: trainee)
      end

      def call
        return STATUSES[:in_progress] if in_progress?
        return STATUSES[:completed] if completed?

        STATUSES[:not_started]
      end

    private

      attr_reader :validator

      def started?
        @validator.fields.values.flatten.compact.any?
      end

      def in_progress?
        started? && (!@validator.valid? || @validator.valid?) && !trainee.progress[:personal_detail]
      end

      def completed?
        @validator.valid? && trainee.progress[:personal_detail]
      end
    end
  end
end
