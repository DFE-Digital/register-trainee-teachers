# frozen_string_literal: true

module Trainees
  class CreateTimelineEvents
    include ServicePattern

    STATE_CHANGE = "state_change"
    IMPORT_SOURCES = %w[DTTP HESA].freeze

    FIELDS = %w[
      trainee_id
      provider_trainee_id
      first_names
      last_name
      date_of_birth
      email
      middle_names
      training_route
      sex
      gender
      diversity_disclosure
      ethnic_group
      ethnic_background
      additional_ethnic_background
      disability_disclosure
      course_subject_one
      itt_start_date
      itt_end_date
      trainee_start_date
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
      employing_school_id
      iqts_country
      withdraw_date
      hesa_editable
      provider_id
    ].freeze

    delegate :user, :created_at, :auditable_type, :audited_changes, :auditable, :comment, to: :audit

    def initialize(audit:, current_user: nil)
      @audit = audit
      @current_user = current_user
    end

    def call
      return if trainee_association_imported_from_dttp?

      if withdrawal_undone? || award_undone?
        title = withdrawal_undone? ? "Withdrawal undone" : "#{auditable.award_type} award removed"
        items = withdrawal_undone? ? undo_message : [undo_comment]

        return TimelineEvent.new(
          title: title,
          date: created_at,
          username: username,
          items: items,
        )
      end

      if action == "create"
        creation_events = [
          TimelineEvent.new(
            title: create_title,
            date: [created_at, auditable&.created_at].compact.min,
            username: username,
          ),
        ]

        if hesa_or_dttp_user? && auditable_type == "Trainee"
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

      if changed_accredited_provider?
        return TimelineEvent.new(
          title: accredited_provider_change_title,
          date: created_at,
          username: username,
          items: changed_accredited_provider_description,
        )
      end

      if changed_placement?
        old_name, name = GetPlacementNameFromAudit.call(audit:)
        return TimelineEvent.new(
          title: I18n.t("components.timeline.titles.placement.update", old_name:, name:),
          date: created_at,
          username: username,
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
      end.compact
    end

  private

    attr_reader :audit, :current_user

    def withdrawal_undone?
      valid_undo?("withdrawn")
    end

    def award_undone?
      valid_undo?("awarded")
    end

    def valid_undo?(state)
      return false unless audited_changes.is_a?(Hash) && username

      change = audited_changes["state"]
      change.is_a?(Array) &&
        change.size == 2 &&
        change[0] == Trainee.states[state] &&
        change[1].is_a?(Integer)
    end

    def undo_message
      [["Comment:", undo_comment]] if comment.present?
    end

    def undo_comment
      comment.split("\n").first
    end

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

    def accredited_provider_change_title
      I18n.t(
        "components.timeline.titles.trainee.accredited_provider_change",
        old_accredited_provider: Provider.find_by(id: audited_changes["provider_id"].first)&.name_and_code,
        new_accredited_provider: Provider.find_by(id: audited_changes["provider_id"].second)&.name_and_code,
      )
    end

    def state_change_action
      change_from, change_to = audited_changes["state"].map { |change| Trainee.states.key(change) }

      # Trainees are occasionally transitioned manually from deferred to awarded
      # and in these cases we don't want the timeline to say "reinstated".
      if change_from == "deferred" && %w[withdrawn awarded].exclude?(change_to)
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
        ]
      end
    end

    def changed_accredited_provider_description
      [comment]
    end

    def create_title
      title_key = "components.timeline.titles.#{model}.create"
      title_args = model == "placement" ? { name: GetPlacementNameFromAudit.call(audit:) } : {}
      title = I18n.t(title_key, **title_args)
      title += " in #{user}" if model != "placement" && hesa_or_dttp_user?
      title
    end

    def import_title
      I18n.t("components.timeline.titles.trainee.import", source: user)
    end

    def destroy_title
      if model == "placement"
        I18n.t("components.timeline.titles.#{model}.destroy", name: GetPlacementNameFromAudit.call(audit:))
      else
        I18n.t("components.timeline.titles.#{model}.destroy")
      end
    end

    def update_title(field)
      title = I18n.t("components.timeline.titles.#{model}.#{field}", default: "#{field.humanize} updated").html_safe
      title += " in #{user}" if hesa_or_dttp_user?
      title
    end

    # The `user` is the user associated with the audit. The `current_user` is
    # the logged in user.
    def username
      return unless user && !user.is_a?(String)

      return "DfE administrator" if user.is_a?(User) && user.system_admin?

      return "#{user.name} (via Register API)" if user.is_a?(Provider)

      return "#{user.name} (#{provider_name})" if current_user&.system_admin?

      return provider_name if current_user != user

      user.name
    end

    def changed_accredited_provider?
      change = audited_changes["provider_id"]

      action == "update" && Array.wrap(change).size == 2
    end

    def changed_placement?
      action == "update" && model == "placement" && audited_changes.keys.intersect?(%w[name school_id])
    end

    def hesa_or_dttp_user?
      IMPORT_SOURCES.include?(user)
    end

    def dttp_user?
      user == "DTTP"
    end

    def trainee_association_imported_from_dttp?
      auditable_type != "Trainee" && action == "create" && dttp_user?
    end

    def provider_name
      Provider.find_by(id: audit.associated_id)&.name_and_code
    end
  end
end
