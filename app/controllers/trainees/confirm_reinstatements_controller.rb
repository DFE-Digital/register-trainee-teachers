# frozen_string_literal: true

module Trainees
  class ConfirmReinstatementsController < BaseController
    def show
      page_tracker.save_as_origin!
      reinstatement
    end

    def update
      if reinstatement.save! || trainee.starts_course_in_the_future?
        trainee.trn.present? ? trainee.receive_trn! : trainee.submit_for_trn!
        flash[:success] = I18n.t("flash.trainee_reinstated")
        redirect_to(trainee_path(trainee))
      end
    end

  private

    def reinstatement
      @reinstatement ||= ReinstatementForm.new(trainee)
    end

    def authorize_trainee
      authorize(trainee, :reinstate?)
    end
  end
end
