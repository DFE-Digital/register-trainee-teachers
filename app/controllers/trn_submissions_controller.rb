# frozen_string_literal: true

class TrnSubmissionsController < ApplicationController
  before_action :authorize_trainee

  def create
    @trn_submission_form = TrnSubmissionForm.new(trainee: trainee)
    return render "trainees/check_details/show" unless @trn_submission_form.valid?

    trainee.submit_for_trn!

    RegisterForTrnJob.perform_later(trainee, current_user.dttp_id)
    RetrieveTrnJob.set(wait: RetrieveTrnJob::POLL_DELAY).perform_later(trainee)

    redirect_to trn_submission_path(trainee)
  end

private

  def trainee
    @trainee ||= Trainee.from_param(params[:trainee_id])
  end

  def authorize_trainee
    authorize(trainee)
  end
end
