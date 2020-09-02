class TraineesController < ApplicationController
  def show
    @trainee = Trainee.find(params[:id])
  end

  def new
    @trainee = Trainee.new
  end

  def create
    trainee = Trainee.create!(trainee_params)
    redirect_to trainee_path(trainee)
  end

  def update
    @trainee = Trainee.find(params[:id])
    @trainee.update!(trainee_params)
    redirect_to trainee_path(@trainee)
  end

private

  def trainee_params
    params.require(:trainee)
          .permit(trainee_all_params)
  end

  def trainee_all_params
    trainee_personal_details_params + trainee_previous_education_params
  end

  def trainee_personal_details_params
    %i[
      trainee_id
      first_names
      last_name
      date_of_birth
      gender
      nationality
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
end
