# frozen_string_literal: true

module Trainees
  class CreateTimelineEvents
    include ServicePattern

    STATE_CHANGE = "state_change"

    FIELDS = %w[
      first_names
      last_name
      date_of_birth
      address_line_one
      address_line_two
      town_city
      postcode
      email
      middle_names
      international_address
      locale_code
      gender
      diversity_disclosure
      ethnic_group
      ethnic_background
      additional_ethnic_background
      disability_disclosure
      subject
      age_range
      course_start_date
      course_end_date
      commencement_date
      uk_degree
      non_uk_degree
      institution
      graduation_year
      grade
      country
      other_grade
    ].freeze

    def initialize(audit:)
      @audit = audit
    end

    def call
      if create_single_event?
        TimelineEvent.new(
          title: single_event_title,
          date: audit.created_at,
          username: audit.user&.name,
        )
      else
        changes.map do |field, _|
          next unless FIELDS.include?(field)

          TimelineEvent.new(
            title: I18n.t("components.timeline.titles.#{model}.#{field}", default: "#{field.humanize} updated"),
            date: audit.created_at,
            username: audit.user&.name,
          )
        end
      end
    end

  private

    attr_reader :audit

    def create_single_event?
      action != "update"
    end

    # An audit's action can be one of "create", "destroy" or "update"
    def action
      @action ||= changes.keys.include?("state") && audit.action == "update" ? STATE_CHANGE : audit.action
    end

    def model
      @model ||= audit.auditable_type.downcase
    end

    # `audited_changes` is a hash representing the changes applied to each field
    # e.g. { field: ['from_value', 'to_value'] }
    def changes
      @changes ||= audit.audited_changes
    end

    def single_event_title
      return state_change_title if action == STATE_CHANGE

      I18n.t("components.timeline.titles.#{model}.#{action}")
    end

    def state_change_title
      change_from, change_to = changes["state"].map { |change| Trainee.states.key(change) }

      if change_from == "deferred" && change_to != "withdrawn"
        I18n.t("components.timeline.titles.trainee.reinstated")
      else
        I18n.t("components.timeline.titles.trainee.#{change_to}")
      end
    end
  end
end
