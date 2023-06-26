# frozen_string_literal: true

module Trainees
  module Withdrawal
    class ReasonsController < Base
    private

      def form_class
        ::Withdrawal::ReasonForm
      end

      def attribute_names
        :reason_ids
      end

      def next_page
        edit_trainee_withdrawal_extra_information_path(trainee)
      end
    end
  end
end
