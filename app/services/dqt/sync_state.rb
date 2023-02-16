# frozen_string_literal: true

# This service has not been updated to use the response from the updated
# Dqt::RetrieveTeacher service.
#
# Before using this service again (for example if we turn back on
# Dqt::SyncStatesJob) we need to be comparing the result from
# Dqt::RetrieveTrainingInstance rather than Dqt::RetrieveTeacher.
module Dqt
  class SyncState
    include ServicePattern

    AWARDED = "Pass"
    WITHDRAWN = "Withdrawn"
    DEFERRED = "Deferred"

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      # return unless FeatureService.enabled?(:integrate_with_dqt)
      # return unless [AWARDED, WITHDRAWN, DEFERRED].include?(dqt_state)

      # Trainees::Update.call(trainee: trainee, params: update_params, update_dqt: false)
    end

  private

    attr_reader :trainee

    # def response
    #   @response ||= Dqt::RetrieveTeacher.call(trainee:)
    # end

    # def dqt_state
    #   @dqt_state ||= response.dig("initial_teacher_training", "result")
    # end

    # def update_params
    #   case dqt_state
    #   when AWARDED
    #     awarded_at = response.dig("qualified_teacher_status", "qts_date")
    #     { state: "awarded", awarded_at: awarded_at }
    #   when WITHDRAWN
    #     { state: "withdrawn", withdraw_reason: WithdrawalReasons::UNKNOWN }
    #   when DEFERRED
    #     { state: "deferred" }
    #   else
    #     {}
    #   end
    # end
  end
end
