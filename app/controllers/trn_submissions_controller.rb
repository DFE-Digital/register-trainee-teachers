# frozen_string_literal: true

class TrnSubmissionsController < ApplicationController
  before_action :authorize_trainee

  def create
    unless trainee.submission_ready?
      @form = TrnSubmissionForm.new(trainee: trainee)
      @form.validate
      return render("trainees/check_details/show")
    end

    trainee.submit_for_trn!

    Dttp::RegisterForTrnJob.perform_later(trainee, current_user.dttp_id)
    Dttp::RetrieveTrnJob.perform_with_default_delay(trainee)

    redirect_to(trn_submission_path(trainee))
  end

private

  def trainee
    @trainee ||= Trainee.from_param(params[:trainee_id])
  end

  def authorize_trainee
    authorize(trainee)
  end
end
