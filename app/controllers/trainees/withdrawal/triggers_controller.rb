# frozen_string_literal: true

module Trainees
  module Withdrawal
    class TriggersController < Base
    private

      def form_class
        ::Withdrawal::TriggerForm
      end

      def attribute_names
        :trigger
      end

      def next_page
        edit_trainee_withdrawal_reason_path(trainee)
      end
    end
  end
end
