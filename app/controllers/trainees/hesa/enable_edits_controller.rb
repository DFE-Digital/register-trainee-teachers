# frozen_string_literal: true

module Trainees
  module Hesa
    class EnableEditsController < BaseController
      def show; end

      def update
        trainee.update(hesa_editable: true)
        redirect_to(trainee_hesa_enable_edits_path(@trainee))
      end

    private

      def authorize_trainee
        policy(trainee).allow_actions?
      end
    end
  end
end
