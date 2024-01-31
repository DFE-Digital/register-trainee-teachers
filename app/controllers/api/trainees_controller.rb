# frozen_string_literal: true

module Api
  class TraineesController < Api::BaseController
    def index
      trainees = provider.trainees # .where(academic_cycle:)
                         .updated_since(since)
                         .order(updated_at: sort_by)
                         .page(page)
                         .per(pagination_per_page)

      if trainees.exists?
        render(json: AppendMetadata.new(trainees).call, status: :ok)
      else
        render(json: { error: "No trainees found" }, status: :not_found)
      end
    end

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
