# frozen_string_literal: true

module Api
  module Trainees
    class DeferralsController < Api::BaseController
      include Api::Serializable

      def create
        success, errors = DeferralService.call(deferral_params, trainee)

        if success
          render(json: { data: serializer_klass.new(trainee).as_hash }, status: :ok)
        else
          render(validation_errors_response(errors:))
        end
      end

    private

      def trainee
        @trainee ||= current_provider&.trainees&.find_by!(slug: params[:trainee_slug])
      end

      def deferral_params
        params.require(:data).permit(:defer_date, :defer_reason)
      end

      def model = :trainee
    end
  end
end
