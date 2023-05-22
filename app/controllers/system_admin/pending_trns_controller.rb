# frozen_string_literal: true

module SystemAdmin
  class PendingTrnsController < ApplicationController
    add_flash_types :dqt_error

    def index
      @trainees = Trainee.submitted_for_trn
    end
  end
end
