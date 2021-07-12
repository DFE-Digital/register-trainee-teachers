# frozen_string_literal: true

module Trainees
  module Diversity
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
      before_action :authorize_trainee

      def show
        page_tracker.save_as_origin!

        if trainee.draft?
          @confirm_detail_form = ConfirmDetailForm.new(mark_as_completed: trainee.progress.diversity)
        end

        data_model = trainee.draft? ? trainee : diversity_form

        @confirmation_component = Diversity::View.new(data_model: data_model)
      end

      def update
        # For draft trainees, diversity information is saved to the DB immediately. But if the user later on
        # decides to not share this information, we need to wipe all the data which diversity_form.save! will do.
        diversity_form.save! if !trainee.draft? || diversity_form.diversity_not_disclosed?

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

      def diversity_form
        @diversity_form ||= DiversityForm.new(trainee)
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
