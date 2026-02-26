# frozen_string_literal: true

module FeedbackItems
  class ChecksController < ApplicationController
    skip_before_action :authenticate

    def show
      @feedback_form = FeedbackForm.new(session.id)

      redirect_to(new_feedback_path) unless @feedback_form.stashed?
    end

    def create
      @feedback_form = FeedbackForm.new(session.id)

      if @feedback_form.save
        redirect_to(feedback_confirmation_path)
      else
        render(:show)
      end
    end
  end
end
