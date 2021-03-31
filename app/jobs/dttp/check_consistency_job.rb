# frozen_string_literal: true

module Dttp
  class CheckConsistencyJob < ApplicationJob
    queue_as :default

    def perform(consistency_check_id)
      @consistency_check = ConsistencyCheck.find(consistency_check_id)
      @dttp_contact_updated_date = Dttp::Contacts::Fetch.call(trainee: trainee).updated_on
      @dttp_placement_assignment_updated_date = Dttp::PlacementAssignments::Fetch.call(placement_assignment_dttp_id: trainee.placement_assignment_dttp_id).updated_at

      if contact_conflict || placement_assignment_conflict
        SlackNotifierService.call(channel: Settings.slack.default_channel, message: "There is Contact and/or Placement Assignment conflict on Dttp", username: "DTTP Conflict Error")
      end
    end

  private

    def trainee
      Trainee.find(@consistency_check.trainee_id)
    end

    def contact_conflict
      @consistency_check.contact_last_updated_at != @dttp_contact_updated_date
    end

    def placement_assignment_conflict
      @consistency_check.placement_assignment_last_updated_at != @dttp_placement_assignment_updated_date
    end
  end
end
