# frozen_string_literal: true

module TraineeStatusCard
  class View < GovukComponent::Base
    attr_reader :state, :user, :target

    STATUS_COLOURS = {
      draft: "grey",
      submitted_for_trn: "turquoise",
      trn_received: "blue",
      recommended_for_qts: "purple",
      qts_awarded: "",
      deferred: "yellow",
      withdrawn: "red",
    }.freeze

    def initialize(state:, user:, target:)
      @state = state
      @user = user
      @target = target
    end

    def count
      if user.system_admin?
        Trainee.where(state: state).count
      else
        Trainee.where(state: state, provider: user.provider).count
      end
    end

    def state_name
      {
        qts_awarded: "QTS awarded",
        trn_received: "TRN received",
        submitted_for_trn: "Pending TRN",
        recommended_for_qts: "QTS recommended",
      }[state] || state.to_s.humanize
    end

    def status_colour
      STATUS_COLOURS[state.to_sym]
    end
  end
end
