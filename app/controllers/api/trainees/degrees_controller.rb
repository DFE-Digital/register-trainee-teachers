# frozen_string_literal: true

module Api
  module Trainees
    class DegreesController < Api::BaseController
      def index
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_id])
        trainee.degrees

        render(
          json: { data: trainee.degrees.map { |degree| DegreeSerializer.for(current_version).new(degree).as_hash } },
          status: :ok,
        )
      end
    end
  end
end
