# frozen_string_literal: true

class TrnSubmissionsController < ApplicationController
  before_action :authenticate

  def show
    authorize trainee_presenter.trainee
  end

  def create
    authorize trainee_presenter.trainee

    Dttp::ContactService::Create.call(trainee: trainee_presenter)

    redirect_to trn_submission_path(trainee_id: params[:trainee_id])
  end

private

  def trainee_presenter
    @trainee_presenter ||= Trainee.find(params[:trainee_id]).then do |trainee|
      Dttp::TraineePresenter.new(trainee: trainee)
    end
  end
end
