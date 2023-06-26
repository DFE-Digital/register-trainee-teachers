# frozen_string_literal: true

module Trainees
  module Withdrawal
    class ExtraInformationsController < Base
    private

      def form_class
        ::Withdrawal::ExtraInformationForm
      end

      def attribute_names
        %i[withdraw_reasons_details withdraw_reasons_dfe_details]
      end

      def next_page
        edit_trainee_withdrawal_confirm_detail_path(trainee)
      end
    end
  end
end
