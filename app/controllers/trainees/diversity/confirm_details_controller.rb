# frozen_string_literal: true

module Trainees
  module Diversity
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
      def show
        page_tracker.save_as_origin!

        if trainee.draft?
          @confirm_detail = ConfirmDetailForm.new(mark_as_completed: trainee.progress.diversity)
        end

        data_model = trainee.draft? ? trainee : DiversityForm.new(trainee)

        @confirmation_component = Trainees::Confirmation::Diversity::View.new(data_model: data_model)
      end

      def update
        DiversityForm.new(trainee).save! unless trainee.draft?

        toggle_trainee_progress_field if trainee.draft?

        flash[:success] = "Trainee diversity updated"

        redirect_to page_tracker.last_origin_page_path || trainee_path(trainee)
      end

    private

      def flash_message_title
        I18n.t("components.confirmation.flash.disclosure")
      end

      def toggle_trainee_progress_field
        trainee.progress.diversity = mark_as_completed_params
        trainee.save!
      end
    end
  end
end
