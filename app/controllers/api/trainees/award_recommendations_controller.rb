# frozen_string_literal: true

module Api
  module Trainees
    class AwardRecommendationsController < Api::BaseController
      include Api::Serializable

      def create
        success, errors = award_recommendation_service_klass.call(award_recommendation_params, trainee)

        if success
          render(json: { data: serializer_klass.new(trainee).as_hash }, status: :accepted)
        else
          render(validation_errors_response(errors:))
        end
      end

    private

      def trainee
        @trainee ||= current_provider&.trainees&.includes(placements: :school)&.find_by!(slug: params.expect(:trainee_slug))
      end

      def award_recommendation_service_klass
        Api::GetVersionedItem.for_service(model: :award_recommendation, version: version)
      end

      def award_recommendation_params
        params.expect(data: award_recommendation_service_klass::ATTRIBUTES)
      end

      def model = :trainee
    end
  end
end
