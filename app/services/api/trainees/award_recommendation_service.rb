# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationService
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ServicePattern

      include Api::ErrorAttributeAdapter

      attribute :qts_standards_met_date
      attribute :record_source, default: -> { Trainee::API_SOURCE }

      attr_reader :trainee

      delegate :itt_start_date, :can_recommend_for_award?, :requires_degree?, to: :trainee, prefix: true

      validates :qts_standards_met_date,
                presence: true,
                date: true,
                date_relative_to_time: { future: false },
                after_itt_start_date: true

      validates_with AwardRecommendationValidator

      def initialize(params, trainee)
        super(params)

        @trainee = trainee
      end

      def call
        return false, errors unless valid?

        trainee.attributes = trainee_attributes
        trainee.recommend_for_award!

        ::Trainees::UpdateIttDataInTra.call(trainee:)

        true
      end

      def trainee_degree_missing?
        degrees.blank?
      end

    private

      delegate :state, :degrees, to: :trainee

      alias_method :degree_id, :degrees

      def trainee_attributes
        {
          outcome_date: qts_standards_met_date,
        }
      end
    end
  end
end
