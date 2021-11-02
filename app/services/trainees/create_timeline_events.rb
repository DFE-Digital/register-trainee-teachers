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
      course_subject_one
      course_start_date
      course_end_date
      commencement_date
      course_max_age
      course_uuid
      course_subject_two
      course_subject_three
      applying_for_bursary
      applying_for_scholarship
      training_initiative
      bursary_tier
      study_mode
      uk_degree
      non_uk_degree
      subject
      institution
      graduation_year
      grade
      country
      other_grade
      lead_school_id
      employing_school_id
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
          items: items,
        )
      else
        audited_changes.map do |field, change|
          next unless FIELDS.include?(field)
          # If a user leaves an already-empty field blank, Rails saves this as
          # an empty string. Ignore this.
          next if change == [nil, ""]

          TimelineEvent.new(
            title: I18n.t("components.timeline.titles.#{model}.#{field}", default: "#{field.humanize} updated"),
            date: created_at,
            username: username,
            items: nil,
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

    def items
      if action == STATE_CHANGE && state_change_action == "withdrawn" && auditable.withdraw_date
        [
          ["#{I18n.t('components.timeline.withdrawal_date')}:", auditable.withdraw_date.strftime("%e %B %Y").to_s],
          ["#{I18n.t('components.timeline.withdrawal_reason')}:", (auditable.additional_withdraw_reason&.upcase_first || auditable.withdraw_reason&.humanize).to_s],
        ]
      end
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
