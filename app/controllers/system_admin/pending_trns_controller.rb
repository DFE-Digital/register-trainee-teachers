# frozen_string_literal: true

module SystemAdmin
  class PendingTrnsController < ApplicationController
    add_flash_types :dqt_error

    def index
      @trainees = Trainee.includes(:dqt_trn_request).submitted_for_trn.undiscarded
    end
  end
end
