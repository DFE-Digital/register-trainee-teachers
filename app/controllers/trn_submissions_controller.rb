class TrnSubmissionsController < ApplicationController
  def show; end

  def create
    redirect_to trn_submission_path(id: params[:trainee_id])
  end
end
