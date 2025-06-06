# frozen_string_literal: true

class TrnSubmissionsController < ApplicationController
  before_action :authorize_trainee

  def create
    unless trainee.submission_ready?
      @form = Submissions::TrnValidator.new(trainee:)
      @form.validate
      return render("trainees/check_details/show")
    end

    unless trainee.starts_course_in_the_future?
      return redirect_to(edit_trainee_start_status_path(trainee))
    end

    Trainees::SubmitForTrn.call(trainee:)
    redirect_to(trn_submission_path(trainee))
  end

private

  def trainee
    @trainee ||= Trainee.from_param(params[:trainee_id])
  end

  def authorize_trainee
    authorize(trainee, :update?)
  end
end
