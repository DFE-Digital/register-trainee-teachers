# frozen_string_literal: true

module FeedbackItems
  class ConfirmationsController < ApplicationController
    skip_before_action :authenticate
  end
end
