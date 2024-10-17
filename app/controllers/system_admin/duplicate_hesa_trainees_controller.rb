# frozen_string_literal: true

module SystemAdmin
  class DuplicateHesaTraineesController < ApplicationController
    before_action { require_feature_flag(:duplicate_checking) }

    helper_method :duplicate_trainees_count

    def index
      @potential_duplicate_trainees = PotentialDuplicateTrainee.grouped .page(params[:page] || 1)
      @trainee_lookup = Trainee.where(
        id: @potential_duplicate_trainees.map(&:trainee_ids).flatten,
      ).includes(:start_academic_cycle, :end_academic_cycle, provider: [:courses]).index_by(&:id)
    end

    def duplicate_trainees_count
      @duplicate_trainees_count ||= PotentialDuplicateTrainee.count
    end
  end
end
