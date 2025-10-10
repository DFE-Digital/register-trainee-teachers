# frozen_string_literal: true

module TraineeName
  class View < ApplicationComponent
    attr_reader :trainee

    def initialize(trainee, prefix: nil)
      @trainee = trainee
      @prefix = prefix
    end

    def render?
      display_text.present?
    end

    def display_text
      [@prefix, trainee.short_name || draft_text].compact.join(" ")
    end

    def draft_text
      t("views.trainees.show.draft") if trainee.draft?
    end
  end
end
