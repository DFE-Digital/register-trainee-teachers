# frozen_string_literal: true

module SystemAdmin
  class PendingAwardsController < ApplicationController
    add_flash_types :dqt_error

    def index
      @trainees = Trainee.recommended_for_award.undiscarded.order(:recommended_for_award_at)
    end
  end
end
