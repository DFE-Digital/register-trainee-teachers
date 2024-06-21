# frozen_string_literal: true

module Api
  module Trainees
    class DeferralService
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ServicePattern

      attribute :defer_date

      attr_reader :trainee

      validates :defer_date,
                presence: true,
                date: true,
                after_itt_start_date: true, if: :requires_start_date?

      validates_with DeferralValidator

      delegate :itt_start_date,
               :itt_not_yet_started?,
               :starts_course_in_the_future?,
               :can_defer?, to: :trainee, prefix: true

      def initialize(params, trainee)
        super(params)

        @trainee = trainee
      end

      def call
        if valid?
          trainee.trainee_start_date = itt_start_date if trainee_itt_start_date.is_a?(Date)
          trainee.defer_date = defer_date
          trainee.defer!

          [true]
        else
          [false, errors]
        end
      end

    private

      def requires_start_date?
        return false if trainee_starts_course_in_the_future?

        !trainee_itt_not_yet_started?
      end

      def itt_start_date
        return if trainee_itt_not_yet_started?

        @itt_start_date ||= ::TraineeStartStatusForm.new(trainee).trainee_start_date
      end
    end
  end
end
