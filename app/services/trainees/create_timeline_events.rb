# frozen_string_literal: true

module Trainees
  class CreateTimelineEvents
    include ServicePattern

    STATE_CHANGE = "state_change"

    FIELDS = %w[
      trainee_id
      first_names
      last_name
      date_of_birth
      address_line_one
      address_line_two
      town_city
      postcode
      email
      middle_names
      training_route
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

    delegate :user, :created_at, :auditable_type, :audited_changes, :auditable, to: :audit

    def initialize(audit:)
      @audit = audit
    end

    def call
      if create_single_event?
        TimelineEvent.new(
          title: single_event_title,
          date: created_at,
          username: username,
        )
      else
        audited_changes.map do |field, _|
          next unless FIELDS.include?(field)

          TimelineEvent.new(
            title: I18n.t("components.timeline.titles.#{model}.#{field}", default: "#{field.humanize} updated"),
            date: created_at,
            username: username,
          )
        end
      end
    end

  private

    attr_reader :audit

    def create_single_event?
      action != "update"
    end

    # An action can be one of "create", "destroy" or "update". Here, we're
    # creating a new "state_change" action as they're displayed differently.
    def action
      @action ||= audited_changes.keys.include?("state") && audit.action == "update" ? STATE_CHANGE : audit.action
    end

    def model
      @model ||= auditable_type.downcase
    end

    def single_event_title
      return state_change_title if action == STATE_CHANGE

      I18n.t("components.timeline.titles.#{model}.#{action}")
    end

    def state_change_title
      I18n.t("components.timeline.titles.trainee.#{state_change_action}")
    end

    def state_change_action
      change_from, change_to = audited_changes["state"].map { |change| Trainee.states.key(change) }

      if change_from == "deferred" && change_to != "withdrawn"
        "reinstated"
      elsif change_to == "recommended_for_award"
        "recommended_for_#{auditable.award_type.downcase}"
      elsif change_to == "awarded"
        "#{auditable.award_type.downcase}_awarded"
      else
        change_to
      end
    end

    def username
      return unless user

      user.system_admin? ? "DfE administrator" : user.name
    end
  end
end
