# frozen_string_literal: true

module Trainees
  class CreateFromApplicationJob < ApplicationJob
    queue_as :apply

    def perform(application)
      CreateFromApply.call(application:)
    end
  end
end
