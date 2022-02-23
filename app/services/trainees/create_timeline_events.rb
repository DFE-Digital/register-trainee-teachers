# frozen_string_literal: true

module Trainees
  class CreateTimelineEvents
    include ServicePattern

    STATE_CHANGE = "state_change"
    IMPORT_SOURCES = %w[DTTP HESA].freeze

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
      itt_start_date
      itt_end_date
      commencement_date
      course_max_age
      course_uuid
      course_subject_two
      course_subject_three
      applying_for_bursary
      applying_for_scholarship
      applying_for_grant
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
      if action == "create"
        creation_events = [
          TimelineEvent.new(
            title: create_title,
            date: [created_at, auditable&.created_at].compact.min,
            username: username,
          ),
        ]

        if hesa_or_dttp_user?
          creation_events <<
            TimelineEvent.new(
              title: import_title,
              date: created_at,
            )
        end

        return creation_events
      end

      if action == "destroy"
        return TimelineEvent.new(
          title: destroy_title,
          date: created_at,
          username: username,
        )
      end

      if action == STATE_CHANGE
        return TimelineEvent.new(
          title: state_change_title,
          date: created_at,
          username: username,
          items: state_change_description,
        )
      end

      audited_changes.map do |field, change|
        next unless FIELDS.include?(field)
        # If a user leaves an already-empty field blank, Rails saves this as
        # an empty string. Ignore this.
        next if change == [nil, ""]

        TimelineEvent.new(
          title: update_title(field),
          date: created_at,
          username: username,
        )
      end
    end

  private

    attr_reader :audit

    # An action can be one of "create", "destroy" or "update". Here, we're
    # creating a new "state_change" action as they're displayed differently.
    def action
      @action ||= audited_changes.keys.include?("state") && audit.action == "update" ? STATE_CHANGE : audit.action
    end

    def model
      @model ||= auditable_type.downcase
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

    def state_change_description
      if state_change_action == "withdrawn" && auditable.withdraw_date
        [
          ["#{I18n.t('components.timeline.withdrawal_date')}:", auditable.withdraw_date.strftime("%e %B %Y").to_s],
          ["#{I18n.t('components.timeline.withdrawal_reason')}:", (auditable.additional_withdraw_reason&.upcase_first || auditable.withdraw_reason&.humanize).to_s],
        ]
      end
    end

    def create_title
      title = I18n.t("components.timeline.titles.#{model}.create")
      title += " in #{user}" if hesa_or_dttp_user?
      title
    end

    def import_title
      I18n.t("components.timeline.titles.trainee.import", source: user)
    end

    def destroy_title
      I18n.t("components.timeline.titles.#{model}.destroy")
    end

    def update_title(field)
      title = I18n.t("components.timeline.titles.#{model}.#{field}", default: "#{field.humanize} updated").html_safe
      title += " in #{user}" if hesa_or_dttp_user?
      title
    end

    def username
      return unless user && !user.is_a?(String)

      user.system_admin? ? "DfE administrator" : user.name
    end

    def hesa_or_dttp_user?
      IMPORT_SOURCES.include?(user)
    end
  end
end
