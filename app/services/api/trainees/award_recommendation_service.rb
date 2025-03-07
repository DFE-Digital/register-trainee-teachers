# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationService
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ServicePattern

      attribute :qts_standards_met_date

      attr_reader :trainee

      delegate :itt_start_date, :can_recommend_for_award?, :requires_degree?, to: :trainee, prefix: true

      validates :qts_standards_met_date,
                presence: true,
                date: true,
                not_future_date: true,
                after_itt_start_date: true

      validates_with AwardRecommendationValidator

      def initialize(params, trainee)
        super(params)

        @trainee = trainee
      end

      def call
        return false, errors unless valid?

        trainee.recommend_for_award!
        trainee.attributes = trainee_attributes

        Dqt::RecommendForAwardJob.perform_later(trainee)
        Survey::ScheduleJob.perform_later(trainee: trainee, event_type: :award) if survey_should_be_scheduled?

        true
      end

      def trainee_degree_missing?
        trainee.degrees.blank?
      end

    private

      def survey_should_be_scheduled?
        # Don't send survey for Assessment Only routes or EYTS awards
        trainee.training_route != :assessment_only &&
          trainee.training_route_manager.award_type != EYTS_AWARD_TYPE
      end

      def trainee_attributes
        {
          outcome_date: qts_standards_met_date,
        }
      end
    end
  end
end
