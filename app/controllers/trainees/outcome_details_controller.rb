# frozen_string_literal: true

module Trainees
  class OutcomeDetailsController < BaseController
    skip_before_action :authorize_trainee

    def confirm
      authorize(trainee, :recommend_for_award?)
      @outcome_form = OutcomeDateForm.new(trainee)
    end

    def recommended
      authorize(trainee, :recommended?)
    end
  end
end
