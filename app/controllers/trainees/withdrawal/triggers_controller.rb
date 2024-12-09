# frozen_string_literal: true

module Trainees
  module Withdrawal
    class TriggersController < Base
      #      def update
      #         @form = form_class.new(trainee)
      #         if form.save!
      #           redirect_to(next_page)
      #         else
      #           render(:edit)
      #         end
      #       end

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
