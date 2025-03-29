# frozen_string_literal: true

module Api
  module Trainees
    class DeferralService
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ServicePattern

      attribute :defer_date
      attribute :defer_reason

      attr_reader :trainee

      validates :defer_date, presence: true, date: true
      validates :defer_reason, length: { maximum: 500 }

      validates_with DeferralValidator

      delegate :itt_not_yet_started?,
               :can_defer?, to: :trainee, prefix: true

      def initialize(params, trainee)
        super(params)

        @trainee = trainee
      end

      def call
        return false, errors unless valid?

        trainee.attributes = trainee_attributes
        trainee.defer!
      end

    private

      def trainee_attributes
        {}.tap do |hash|
          hash[:defer_date]         = defer_date
          hash[:defer_reason]       = defer_reason
          hash[:trainee_start_date] = itt_start_date if itt_start_date.is_a?(Date)
        end
      end

      def itt_start_date
        return if trainee_itt_not_yet_started?

        @itt_start_date ||= ::TraineeStartStatusForm.new(trainee).trainee_start_date
      end
    end
  end
end
