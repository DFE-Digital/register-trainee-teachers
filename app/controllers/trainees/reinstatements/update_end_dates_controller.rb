# frozen_string_literal: true

module Trainees
  module Reinstatements
    class UpdateEndDatesController < BaseController
      before_action :redirect_to_confirm_reinstatement, if: -> { trainee.starts_course_in_the_future? }

      before_action :redirect_to_reinstatement, if: -> { reinstatement_form.date.blank? }

      PARAM_CONVERSION = {
        "itt_end_date(3i)" => "day",
        "itt_end_date(2i)" => "month",
        "itt_end_date(1i)" => "year",
      }.freeze

      def show
        @itt_end_date_form = IttEndDateForm.new(trainee)
      end

      def update
        @itt_end_date_form = IttEndDateForm.new(trainee, params: trainee_params, user: current_user)

        if @itt_end_date_form.stash
          redirect_to(trainee_confirm_reinstatement_path(trainee))
        else
          render(:show)
        end
      end

    private

      def trainee_params
        params.require(:itt_end_date_form).permit(:itt_end_date, :context, *PARAM_CONVERSION.keys)
          .transform_keys do |key|
            PARAM_CONVERSION.keys.include?(key) ? PARAM_CONVERSION[key] : key
          end
      end

      def authorize_trainee
        authorize(trainee, :reinstate?)
      end

      def reinstatement_form
        @reinstatement_form ||= ReinstatementForm.new(trainee)
      end
    end
  end
end
