# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationService
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ServicePattern

      ATTRIBUTE_MAPPER = {
        date: :qts_standards_met_date,
      }.freeze

      attribute :qts_standards_met_date

      attr_reader :trainee

      delegate :itt_start_date, :can_recommend_for_award?, to: :trainee

      validates :qts_standards_met_date, presence: true, date: true

      validates_with AwardRecommendationValidator

      def initialize(params, trainee)
        super(params)

        @trainee = trainee
      end

      def call
        if valid?
          trainee.recommend_for_award!
          trainee.attributes = trainee_attributes

          Dqt::RecommendForAwardJob.perform_later(trainee)

          [true]
        else
          [false, errors]
        end
      end

      private_constant :ATTRIBUTE_MAPPER

    private

      def trainee_attributes
        {
          outcome_date: qts_standards_met_date,
        }
      end
    end
  end
end
