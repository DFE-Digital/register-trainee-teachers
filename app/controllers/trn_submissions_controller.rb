class TrnSubmissionsController < ApplicationController
  def show; end

  def create
    Dttp::ContactService::Create.call(trainee: trainee)

    redirect_to trn_submission_path(id: params[:trainee_id])
  end

private

  def trainee
    @trainee ||= Trainee.find(params[:trainee_id]).then do |trainee|
      Dttp::TraineePresenter.new(trainee: trainee)
    end
  end
end
