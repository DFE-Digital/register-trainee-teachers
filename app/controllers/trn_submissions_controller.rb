# frozen_string_literal: true

class TrnSubmissionsController < ApplicationController
  before_action :authenticate

  def show
    authorize trainee
  end

  def create
    authorize trainee

    Dttp::ContactService::Create.call(trainee: Dttp::TraineePresenter.new(trainee: trainee))

    redirect_to trn_submission_path(trainee_id: trainee.id)
  end

private

  def trainee
    @trainee ||= Trainee.find(params[:trainee_id])
  end
end
