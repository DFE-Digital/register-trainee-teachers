# frozen_string_literal: true

module Trainees
  class OutcomeDetailsController < BaseController
    def confirm
      @outcome_form = OutcomeDateForm.new(trainee)
    end

    def recommended
      authorize(trainee, :show_recommended?)
    end
  end
end
