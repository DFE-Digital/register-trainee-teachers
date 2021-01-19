# frozen_string_literal: true

module Trainees
  module Timeline
    class View < GovukComponent::Base
      delegate :audits, :provider, to: :trainee

      Event = Struct.new(:title, :username, :date)

      def initialize(trainee)
        @trainee = trainee
      end

    private

      attr_reader :trainee

      def events
        state_change_events
          .append(creation_event)
          .compact.sort_by(&:date).reverse
      end

      def creation_event
        return nil unless creation_audit

        Event.new(
          I18n.t("components.timeline.titles.created"),
          username(creation_audit),
          creation_audit.created_at,
        )
      end

      def state_change_events
        state_change_audits.map do |audit|
          Event.new(
            state_change_title(audit.audited_changes["state"][1]),
            username(audit),
            audit.created_at,
          )
        end
      end

      def creation_audit
        @creation_audit ||= audits.find { |audit| audit.action == "create" }
      end

      def state_change_audits
        @state_change_audits ||= audits.select do |audit|
          audit.action == "update" && audit.audited_changes.key?("state")
        end
      end

      def state_change_title(value)
        I18n.t("components.timeline.titles.#{Trainee.states.key(value)}")
      end

      # Fall back on the provider's name if there's no user for the audit, e.g.
      # it was created by a background job.
      def username(audit)
        audit.user&.name || provider.name
      end
    end
  end
end
