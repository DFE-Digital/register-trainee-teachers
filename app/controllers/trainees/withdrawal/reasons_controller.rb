# frozen_string_literal: true

module Trainees
  module Withdrawal
    class ReasonsController < Base
      helper_method :another_reason, :reasons

    private

      def reasons
        form.reasons
      end

      def form_class
        ::Withdrawal::ReasonForm
      end

      def attribute_names
        form_class::FIELDS
      end

      def next_page
        edit_trainee_withdrawal_extra_information_path(trainee)
      end
    end
  end
end
