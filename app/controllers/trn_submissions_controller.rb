# frozen_string_literal: true

class TrnSubmissionsController < ApplicationController
  before_action :authorize_trainee

  def create
    RegisterForTrnJob.perform_later(trainee.id, current_user.dttp_id)
    RetrieveTrnJob.set(wait: RetrieveTrnJob::POLL_DELAY).perform_later(trainee.id)

    redirect_to trn_submission_path(trainee_id: trainee.id)
  end

private

  def trainee
    @trainee ||= Trainee.from_param(params[:trainee_id])
  end

  def authorize_trainee
    authorize(trainee)
  end
end
