module Trainees
  module Diversity
    class BaseController < ApplicationController
      before_action :redirect_to_confirm, if: :section_completed?

    private

      def redirect_to_confirm
        redirect_to(trainee_diversity_disclosure_confirm_path(trainee))
      end

      def section_completed?
        ProgressService.call(
          validator: Diversities::DiversityFlow.new(trainee),
          progress_value: trainee.progress.diversity,
        ).completed?
      end
    end
  end
end
