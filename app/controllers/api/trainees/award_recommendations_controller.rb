# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationsController < Api::BaseController
      include Api::Serializable

      def create
        success, errors = AwardRecommendationService.call(award_recommendation_params, trainee)

        if success
          render(json: { data: serializer_klass.new(trainee).as_hash }, status: :accepted)
        else
          render(validation_errors_response(errors:))
        end
      end

    private

      def trainee
        @trainee ||= current_provider&.trainees&.find_by!(slug: params[:trainee_slug])
      end

      def award_recommendation_params
        params.expect(data: [:qts_standards_met_date])
      end

      def model = :trainee
    end
  end
end
