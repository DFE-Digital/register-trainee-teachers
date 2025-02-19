# frozen_string_literal: true

module Trainees
  module Withdrawal
    class ReasonsController < Base
    private

      def form_class
        ::Withdrawal::ReasonForm
      end

      def attribute_names
        form_class::FIELDS
      end

      def next_page
        edit_trainee_withdrawal_future_interest_path(trainee)
      end
    end
  end
end
