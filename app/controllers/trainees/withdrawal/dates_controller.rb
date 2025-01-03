# frozen_string_literal: true

module Trainees
  module Withdrawal
    class DatesController < Base
      def edit
        @form = form_class.new(trainee)
        if @form.uses_deferral_date?
          redirect_to(next_page)
        else
          super
        end
      end

    private

      def form_class
        ::Withdrawal::DateForm
      end

      def attribute_names
        :date_string
      end

      def next_page
        edit_trainee_withdrawal_trigger_path(trainee)
      end

      def form_params
        params
          .require(form_param_key)
          .permit(attribute_names, *MultiDateForm::PARAM_CONVERSION.keys)
          .transform_keys do |key|
            MultiDateForm::PARAM_CONVERSION.fetch(key, key)
          end
      end
    end
  end
end
