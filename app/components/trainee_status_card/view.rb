# frozen_string_literal: true

module TraineeStatusCard
  class View < GovukComponent::Base
    attr_reader :state, :trainees, :target

    STATUS_COLOURS = {
      draft: "grey",
      submitted_for_trn: "turquoise",
      trn_received: "blue",
      recommended_for_qts: "purple",
      qts_awarded: "",
      deferred: "yellow",
      withdrawn: "red",
    }.freeze

    def initialize(state:, trainees:, target:)
      @state = state
      @target = target
      @trainees = trainees
    end

    def count
      trainees.where(state: state).count
    end

    def state_name
      I18n.t("activerecord.attributes.trainee.states.#{state}")
    end

    def status_colour
      STATUS_COLOURS[state.to_sym]
    end
  end
end
