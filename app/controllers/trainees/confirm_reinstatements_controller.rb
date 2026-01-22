# frozen_string_literal: true

module Trainees
  class ConfirmReinstatementsController < BaseController
    def show
      page_tracker.save_as_origin!
      reinstatement_form
      itt_end_date_form
    end

    def update
      if (reinstatement_form.save! && itt_end_date_form.save!) || trainee.starts_course_in_the_future?
        trainee.trn.present? ? trainee.receive_trn! : trainee.submit_for_trn!
        flash[:success] = I18n.t("flash.trainee_reinstated")

        Trainees::UpdateIttDataInTra.call(trainee:)

        redirect_to(trainee_path(trainee))
      end
    end

  private

    def reinstatement_form
      @reinstatement_form ||= ReinstatementForm.new(trainee)
    end

    def itt_end_date_form
      @itt_end_date_form ||= IttEndDateForm.new(trainee)
    end

    def authorize_trainee
      authorize(trainee, :reinstate?)
    end
  end
end
