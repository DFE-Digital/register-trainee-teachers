class TraineesController < ApplicationController
  def show; end

  def new
    @trainee = Trainee.new
  end

  def create
    trainee = Trainee.create(trainee_params)
    redirect_to trainee_path(trainee)
  end

private

  def trainee_params
    params.require(:trainee)
          .permit(:trainee_id,
                  :first_names,
                  :last_name,
                  :date_of_birth,
                  :gender,
                  :nationality,
                  :ethnicity,
                  :disability)
  end
end
