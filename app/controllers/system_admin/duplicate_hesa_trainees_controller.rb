# frozen_string_literal: true

module SystemAdmin
  class DuplicateHesaTraineesController < ApplicationController
    def index
      @potential_duplicate_trainees = PotentialDuplicateTrainee
        .select(:group_id, "array_agg(trainee_id) as trainee_ids", "max(trainees.created_at) as max_created_at")
        .joins(:trainee)
        .group(:group_id)
        .order(max_created_at: :desc)
        .page(params[:page] || 1)
      @trainee_lookup = Trainee.where(
        id: @potential_duplicate_trainees.map(&:trainee_ids).flatten,
      ).includes(:start_academic_cycle, :end_academic_cycle, provider: [:courses]).index_by(&:id)
    end
  end
end
