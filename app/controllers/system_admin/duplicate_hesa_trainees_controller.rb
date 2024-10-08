# frozen_string_literal: true

module SystemAdmin
  class DuplicateHesaTraineesController < ApplicationController
    def index
      @potential_duplicate_trainees = PotentialDuplicateTrainee
        .includes(:trainee)
        .order(:group_id, created_at: :desc)
        .page(params[:page] || 1)
    end

    def show
    end
  end
end
