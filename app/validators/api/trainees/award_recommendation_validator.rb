# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationValidator < ActiveModel::Validator
      include DatesHelper

      def validate(record)
        return unless record.errors[:qts_standards_met_date].empty?

        parsed_qts_standards_met_date = Date.parse(record.qts_standards_met_date)

        record.errors.add(:trainee, :state) unless record.can_recommend_for_award?
        record.errors.add(:qts_standards_met_date, :future) if parsed_qts_standards_met_date.future?
        record.errors.add(:qts_standards_met_date, :itt_start_date) if date_before_itt_start_date?(parsed_qts_standards_met_date, record.itt_start_date)
      end
    end
  end
end
