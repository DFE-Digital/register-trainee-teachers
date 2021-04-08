# frozen_string_literal: true

module Dttp
  class CheckConsistencyJob < ApplicationJob
    queue_as :default

    def perform(consistency_check_id)
      @consistency_check = ConsistencyCheck.find(consistency_check_id)
      @dttp_contact_updated_date = Dttp::Contacts::Fetch.call(contact_entity_id: trainee.dttp_id).updated_at
      @dttp_placement_assignment_updated_date = Dttp::PlacementAssignments::Fetch.call(placement_assignment_dttp_id: trainee.placement_assignment_dttp_id).updated_at

      if contact_conflict || placement_assignment_conflict
        SlackNotifierService.call(channel: Settings.slack.publish_register_alerts_channel, message: "<#{Rails.application.routes.url_helpers.trainees_url(trainee, host: Settings.base_url)}|Trainee #{trainee.id} has been updated in DTTP>", username: "DTTP Conflict Error")
      end
    end

  private

    attr_reader :consistency_check, :dttp_contact_updated_date, :dttp_placement_assignment_updated_date

    def trainee
      Trainee.find(consistency_check.trainee_id)
    end

    def contact_conflict
      consistency_check.contact_last_updated_at != dttp_contact_updated_date
    end

    def placement_assignment_conflict
      consistency_check.placement_assignment_last_updated_at != dttp_placement_assignment_updated_date
    end
  end
end
