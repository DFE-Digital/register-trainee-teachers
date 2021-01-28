# frozen_string_literal: true

module Trainees
  module Diversity
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
      include Breadcrumbable

      def show
        authorize trainee
        save_origin_page_for(trainee)
        @confirm_detail = ConfirmDetailForm.new(mark_as_completed: trainee.progress.diversity)
        @confirmation_component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      end

    private

      def flash_message_title
        I18n.t("components.confirmation.flash.disclosure")
      end

      def toggle_trainee_progress_field
        trainee.progress.diversity = mark_as_completed_params
      end
    end
  end
end
