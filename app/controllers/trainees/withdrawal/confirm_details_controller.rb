# frozen_string_literal: true

module Trainees
  module Withdrawal
    class ConfirmDetailsController < Base
      def update
        @form = form_class.new(trainee)
        if form.save!
          flash[:success] = t("trainees.withdrawals.confirm_details.update.success")
          redirect_to(trainee_path(trainee))
        else
          flash[:error] = t("trainees.withdrawals.confirm_details.update.error")
          render(:edit)
        end
      end

    private

      def form_class
        ::Withdrawal::ConfirmDetailsForm
      end

      def attribute_names
        []
      end
    end
  end
end
