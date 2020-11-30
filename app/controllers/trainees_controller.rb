# frozen_string_literal: true

class TraineesController < ApplicationController
  def index
    @trainees = policy_scope(Trainee)
  end

  def show
    authorize trainee
    @pre_submission_checker = Trns::SubmissionChecker.call(trainee)
  end

  def new
    skip_authorization
    @trainee = Trainee.new
  end

  def create
    if trainee_params[:record_type] == "other"
      redirect_to trainees_not_supported_route_path
    else
      authorize @trainee = Trainee.new(trainee_params.merge(provider_id: current_user.provider_id))
      if trainee.save
        redirect_to trainee_path(trainee)
      else
        render :new
      end
    end
  end

  def edit
    authorize trainee
  end

  def update
    authorize trainee
    trainee.update!(trainee_params)
    redirect_to trainee_path(trainee)
  end

private

  def trainee
    @trainee ||= Trainee.find(params[:id])
  end

  def trainee_params
    params.require(:trainee).permit(trainee_all_params, nationality_ids: [])
  end

  def trainee_all_params
    [
      trainee_record_params,
      trainee_personal_details_params,
      trainee_previous_education_params,
      trainee_training_details_params,
    ].flatten
  end

  def trainee_record_params
    %i[
      record_type
      trainee_id
    ]
  end

  def trainee_personal_details_params
    %i[
      first_names
      middle_names
      last_name
      date_of_birth
      gender
      ethnicity
      disability
    ]
  end

  def trainee_previous_education_params
    %i[
      a_level_1_subject
      a_level_1_grade
      a_level_2_subject
      a_level_2_grade
      a_level_3_subject
      a_level_3_grade
      degree_subject
      degree_class
      degree_institution
      degree_type
      ske
      previous_qts
    ]
  end

  def trainee_training_details_params
    %i[
      start_date
      full_time_part_time
      teaching_scholars
    ]
  end
end
