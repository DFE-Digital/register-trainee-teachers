# frozen_string_literal: true

module Trainees
  module Placements
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
      include TraineeHelper

      def update
        trainee.draft? ? toggle_trainee_progress_field : @form.save!

        flash[:success] = "Trainee #{flash_message_title} updated"

        redirect_to(page_tracker.last_origin_page_path || trainee_path(trainee))
      end

    private

      def authorize_trainee
        policy(trainee).write_placements?
      end
    end
  end
end
