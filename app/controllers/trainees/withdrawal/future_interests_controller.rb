# frozen_string_literal: true

module Trainees
  module Withdrawal
    class FutureInterestsController < Base
    private

      def form_class
        ::Withdrawal::FutureInterestForm
      end

      def attribute_names
        :future_interest
      end

      def next_page
        edit_trainee_withdrawal_confirm_detail_path(trainee)
      end
    end
  end
end
