# frozen_string_literal: true

module HesaWarningInset
  class View < ApplicationComponent
    def initialize(trainee:, current_user:)
      @trainee = trainee
      @current_user = current_user
    end

    delegate :hesa_editable?, :hesa_updated_at, to: :@trainee

    def render?
      @trainee.hesa_record? && @trainee.awaiting_action? && @current_user.provider?
    end
  end
end
