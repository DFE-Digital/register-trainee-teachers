# frozen_string_literal: true

module Api
  class TraineesController < Api::BaseController
    def show
      trainee = current_provider&.trainees&.find_by(slug: params[:id])
      if trainee.present?
        render(json: TraineeSerializer.new(trainee).as_json)
      else
        render(json: { error: "Trainee not found" }, status: :not_found)
      end
    end
  end
end
