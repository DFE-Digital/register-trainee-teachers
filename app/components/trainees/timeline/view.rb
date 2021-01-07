# frozen_string_literal: true

module Trainees
  module Timeline
    class View < GovukComponent::Base
      delegate :created_at, :submitted_for_trn_at, :provider, to: :trainee

      def initialize(trainee)
        @trainee = trainee
      end

      Event = Struct.new(:title, :actor, :date)

    private

      attr_reader :trainee

      # TODO: Once we implement auditing, this will be an array of audit events.
      # We'll iterate over a trainee's audit events, pull out ones we care about,
      # and map them to timeline `Event`s accordingly.
      def events
        [
          creation_event,
          submitted_for_trn_event,
        ].compact.sort_by(&:date).reverse
      end

      def creation_event
        Event.new("Record created", temp_actor, created_at)
      end

      def submitted_for_trn_event
        if submitted_for_trn_at
          Event.new("Trainee submitted for TRN", temp_actor, submitted_for_trn_at)
        end
      end

      # TODO: This will be pulled from the audit event. Until then, we don't
      # actually know which user made the change, so this is a placeholder.
      def temp_actor
        provider.users.first.name
      end
    end
  end
end
