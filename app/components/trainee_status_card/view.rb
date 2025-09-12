# frozen_string_literal: true

module TraineeStatusCard
  class View < ApplicationComponent
    attr_reader :status, :count, :target

    STATUS_COLOURS = {
      course_not_started_yet: "",
      in_training: "",
      awarded_this_year: "",
      deferred: "yellow",
      incomplete: "grey",
      can_complete: "grey",
    }.freeze

    def initialize(status:, count:, target:)
      @status = status
      @target = target
      @count = count
    end

    def state_name
      I18n.t("components.trainee_status_card.#{status}")
    end

    def status_colour
      STATUS_COLOURS[status.to_sym]
    end
  end
end
