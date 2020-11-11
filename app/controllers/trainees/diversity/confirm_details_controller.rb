module Trainees
  module Diversity
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
      def show
        @confirm_detail = ConfirmDetail.new(mark_as_completed: trainee.progress.diversity)
        @confirmation_component = Trainees::Confirmation::Diversity::View.new(trainee: trainee)
      end

    private

      def toggle_trainee_progress_field
        trainee.progress.diversity = mark_as_completed_params
      end
    end
  end
end
