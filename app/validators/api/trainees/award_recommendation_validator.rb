# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationValidator < ActiveModel::Validator
      def validate(record)
        return unless record.errors[:qts_standards_met_date].empty?

        record.errors.add(:trainee, :state) unless record.trainee_can_recommend_for_award?
      end
    end
  end
end
