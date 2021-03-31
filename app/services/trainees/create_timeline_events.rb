# frozen_string_literal: true

module Trainees
  class CreateTimelineEvents
    include ServicePattern

    IGNORED_EVENTS = %w[progress].freeze

    def initialize(audits:)
      @audits = audits
    end

    def call
      events.flatten.compact.sort_by(&:date).reverse
    end

  private

    attr_reader :audits

    def events
      audits.map do |audit|
        # Create one 'master' event for the creation of a trainee
        if is_trainee_creation?(audit)
          TimelineEvent.new(
            title: I18n.t("components.timeline.titles.created"),
            date: audit.created_at,
            username: audit.user&.name,
          )

        # Create one 'master' event when the trainee's state changes
        elsif is_state_change?(audit)
          TimelineEvent.new(
            title: state_change_title(audit),
            date: audit.created_at,
            username: audit.user&.name,
          )

        # Create _multiple_ events for when the user submits a form with multiple fields
        else
          audit.audited_changes.map do |field, _|
            next if IGNORED_EVENTS.include?(field)

            TimelineEvent.new(
              title: I18n.t(
                "components.timeline.titles.#{field}",
                default: "Trainee #{field.humanize(capitalize: false)} updated",
              ),
              date: audit.created_at,
              username: audit.user&.name,
            )
          end
        end
      end
    end

    def is_trainee_creation?(audit)
      audit.action == "create" && audit.auditable_type = "Trainee"
    end

    def is_state_change?(audit)
      audit.audited_changes.keys.include?("state")
    end

    def state_change_title(audit)
      change_from, change_to = audit.audited_changes["state"].map { |change| Trainee.states.key(change) }

      if change_from == "deferred" && change_to != "withdrawn"
        I18n.t("components.timeline.titles.reinstated")
      else
        I18n.t("components.timeline.titles.#{change_to}")
      end
    end
  end
end
