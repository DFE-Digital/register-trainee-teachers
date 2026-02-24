# frozen_string_literal: true

class FeedbackItemsController < ApplicationController
  def new
    @feedback_form = FeedbackForm.new(session.id)
  end

  def create
    @feedback_form = FeedbackForm.new(session.id, params: feedback_params)

    if @feedback_form.stash
      redirect_to(feedback_check_path)
    else
      render(:new)
    end
  end

private

  def feedback_params
    params.expect(feedback_form: %i[satisfaction_level improvement_suggestion name email])
  end
end
