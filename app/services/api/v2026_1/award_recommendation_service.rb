# frozen_string_literal: true

module Api
  module V20261
    class AwardRecommendationService < Api::Trainees::AwardRecommendationService
      ATTRIBUTES = %i[qts_standards_met_date].freeze
    end
  end
end
