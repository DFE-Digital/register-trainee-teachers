# frozen_string_literal: true

module Trainees
  module Diversity
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
      before_action :authorize_trainee
      before_action :save_data_and_bypass_confirmation_page, if: :draft_apply_application?
      before_action :load_missing_data_view

      def show
        page_tracker.save_as_origin!

        if trainee.draft?
          @confirm_detail_form = ConfirmDetailForm.new(mark_as_completed: trainee.progress.diversity)
        end

        @confirmation_component = ::Diversity::View.new(data_model: data_model)
      end

      def update
        if form.valid?
          # For draft trainees, diversity information is saved to the DB immediately. But if the user later on
          # decides to not share this information, we need to wipe all the data which diversity_form.save! will do.
          form.save! if !trainee.draft? || form.diversity_not_disclosed?

          toggle_trainee_progress_field if trainee.draft?

          flash[:success] = "Trainee diversity updated"

          redirect_to page_tracker.last_origin_page_path || trainee_path(trainee)
        else
          @confirmation_component = ::Diversity::View.new(data_model: data_model, has_errors: true)

          render :show
        end
      end

    private

      def data_model
        trainee.draft? ? trainee : form
      end

      def form
        @form ||= build_form
      end

      def flash_message_title
        I18n.t("components.confirmation.flash.disclosure")
      end

      def toggle_trainee_progress_field
        trainee.progress.diversity = mark_as_completed_params
        trainee.save!
      end

      def load_missing_data_view
        @missing_data_view = MissingDataView.new(build_form)
      end

      def build_form
        DiversityForm.new(trainee)
      end

      def save_data_and_bypass_confirmation_page
        form.save!
        redirect_to edit_trainee_apply_applications_trainee_data_path(trainee)
      end

      def draft_apply_application?
        trainee.draft? && trainee.apply_application?
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
