# frozen_string_literal: true

module TraineeName
  class View < ApplicationComponent
    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end

    def render?
      display_text.present?
    end

    def display_text
      trainee.short_name || draft_text
    end

    def draft_text
      t("views.trainees.show.draft") if trainee.draft?
    end
  end
end
