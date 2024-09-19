# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationValidator < ActiveModel::Validator
      def validate(record)
        return unless record.errors.empty?

        record.errors.add(:trainee, :degrees) if record.trainee_requires_degree? && record.trainee_degree_missing?
        record.errors.add(:trainee, :state) unless record.trainee_can_recommend_for_award?
      end
    end
  end
end
