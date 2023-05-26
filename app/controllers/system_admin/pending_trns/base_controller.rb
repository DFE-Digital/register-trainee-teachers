# frozen_string_literal: true

module SystemAdmin
  module PendingTrns
    class BaseController < ApplicationController
      include TraineeHelper

      add_flash_types :dqt_error
      before_action :load_trainee

    private

      attr_reader :trainee

      def load_trainee
        @trainee = Trainee.from_param(params[:id])
      end

      def trn_request
        @trn_request = trainee.dqt_trn_request
      end
    end
  end
end
