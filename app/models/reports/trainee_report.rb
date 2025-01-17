# frozen_string_literal: true

module Reports
  class TraineeReport
    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end

    # rubocop:disable Naming/VariableNumber
    delegate :country,
             :grade,
             :graduation_year,
             :other_grade,
             :subject,
             to: :degree,
             prefix: :degree_1,
             allow_nil: true
    delegate :course_duration_in_years,
             :ethnic_background,
             :first_names,
             :middle_names,
             :trn,
             :withdraw_reasons_details,
             :withdraw_reasons_dfe_details,
             :course_subject_one,
             :course_subject_two,
             :course_subject_three,
             :provider_trainee_id,
             to: :trainee,
             allow_nil: true

    def degree
      @degree ||= trainee.degrees.first
    end

    def course
      @course ||= Course.includes(:provider).find_by(uuid: trainee.course_uuid)
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end

    def academic_years
      return unless trainee.start_academic_cycle && trainee.end_academic_cycle

      start_years = trainee.start_academic_cycle.start_year..trainee.end_academic_cycle.start_year

      start_years.map { |year| "#{year} to #{year + 1}" }.join(", ")
    end
    # rubocop:enable Naming/VariableNumber

    def apply_id
      trainee.apply_application&.apply_id
    end

    def award_given_at
      return "Currently no data available in Register" if # TODO: move text to translation file
        trainee.awarded_at.blank? && trainee.hesa_record? && trainee.awarded?

      trainee.awarded_at&.iso8601
    end

    def placement_one
      return "" if placements.empty?

      placement = placements.first

      placement.school_id.present? ? placement.school.urn : placement.name
    end

    def placement_two
      return "" if placements.size < 2

      placement = placements.second

      placement.school_id.present? ? placement.school.urn : placement.name
    end

    def other_placements
      return "" if placements.size < 3

      # Fetches the school ids for the remaining placements (e.g from the 3rd, onwards)
      school_ids = placements[2..].pluck(:school_id).compact

      school_urns = School.where(id: school_ids).pluck(:urn)

      school_urns.join(", ")
    end

    def award_standards_met_date
      trainee.outcome_date&.iso8601
    end

    def bursary_tier
      {
        "tier_one" => "Tier 1",
        "tier_two" => "Tier 2",
        "tier_three" => "Tier 3",
      }[trainee.bursary_tier]
    end

    def course_education_phase
      return EARLY_YEARS_ROUTE_NAME_PREFIX.humanize if trainee.early_years_route?

      trainee.course_education_phase&.upcase_first || course&.level&.capitalize
    end

    def course_full_or_part_time
      trainee.study_mode&.humanize
    end

    # rubocop:disable Naming/VariableNumber
    def course_itt_subject_1
      trainee.course_subject_one
    end

    def course_itt_subject_2
      trainee.course_subject_two
    end

    def course_itt_subject_3
      trainee.course_subject_three
    end
    # rubocop:enable Naming/VariableNumber

    def course_level
      trainee.undergrad_route? ? "undergrad" : "postgrad"
    end

    def course_maximum_age
      trainee.course_max_age
    end

    def course_minimum_age
      trainee.course_min_age
    end

    def course_qualification
      trainee.award_type
    end

    def course_subject_category
      trainee.course_allocation_subject&.name
    end

    def course_subject_names
      @course_subject_names ||= course.subjects.pluck(:name)
    end

    def course_training_route
      I18n.t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
    end

    def subjects
      additional_subjects = [course_subject_two, course_subject_three].compact_blank.join(" and ")

      [course_subject_one&.upcase_first, additional_subjects].compact_blank.join(" with ")
    end

    def date_of_birth
      trainee.date_of_birth&.iso8601
    end

    def defer_date
      return "Not required by HESA so no data available in Register" if # TODO: move text to translation file
        trainee.defer_date.blank? && trainee.hesa_record? && trainee.deferred?

      trainee.defer_date&.iso8601
    end

    def degree_1_awarding_institution
      degree&.institution
    end

    def degree_1_type_non_uk
      degree&.non_uk_degree
    end

    def degree_1_type_uk
      degree&.uk_degree
    end

    def degree_1_uk_or_non_uk
      return if degree.blank?

      degree.locale_code.gsub("_", "-").gsub("uk", "UK")
    end

    def degrees
      trainee.degrees.map do |degree|
        [
          degree_1_uk_or_non_uk,
          degree.institution,
          degree.country,
          degree.subject,
          degree.uk_degree,
          degree.non_uk_degree,
          degree.grade,
          degree.other_grade,
          degree.graduation_year,
        ].map { |d| "\"#{d}\"" }.join(", ")
      end.join(" | ")
    end

    def disabilities
      trainee.disabilities.map do |disability|
        if disability.name == Diversities::OTHER
          trainee.trainee_disabilities.find { |x| x.disability_id == disability.id }.additional_disability
        else
          disability.name
        end
      end.join(", ")
    end

    def disability_disclosure
      return if trainee.disability_disclosure.blank?

      {
        "disabled" => "Has disabilities",
        "disability_not_provided" => "Not provided",
        "no_disability" => "No disabilities",
      }[trainee.disability_disclosure]
    end

    def diversity_disclosure
      return if trainee.diversity_disclosure.blank?

      trainee.diversity_disclosure == "diversity_disclosed" ? "TRUE" : "FALSE"
    end

    def email_address
      trainee.email
    end

    def employing_school_name
      trainee.employing_school_not_applicable? ? I18n.t(:not_applicable) : trainee.employing_school&.name
    end

    def employing_school_urn
      trainee.employing_school&.urn
    end

    def end_academic_year
      trainee.end_academic_cycle&.label
    end

    def ethnic_background_additional
      trainee.additional_ethnic_background
    end

    def ethnic_group
      I18n.t("components.confirmation.diversity.ethnic_groups.#{trainee.ethnic_group.presence || 'not_provided_ethnic_group'}")
    end

    def expected_end_date
      return "End date not required by HESA so no data available in Register" if # TODO: move text to translation file
        trainee.itt_end_date.blank? && trainee.hesa_record? && !trainee.awaiting_action?

      trainee.itt_end_date&.iso8601
    end

    def funding_method
      if trainee.applying_for_bursary?
        FUNDING_TYPE_ENUMS[:bursary]
      elsif trainee.applying_for_scholarship?
        FUNDING_TYPE_ENUMS[:scholarship]
      elsif trainee.applying_for_grant?
        FUNDING_TYPE_ENUMS[:grant]
      elsif [trainee.applying_for_bursary, trainee.applying_for_scholarship, trainee.applying_for_grant].include?(false)
        "not funded"
      elsif !funding_manager.funding_available?
        "not available"
      end
    end

    def funding_value
      if trainee.applying_for_bursary?
        funding_manager.bursary_amount || "data not available"
      elsif trainee.applying_for_scholarship?
        funding_manager.scholarship_amount || "data not available"
      elsif trainee.applying_for_grant?
        funding_manager.grant_amount || "data not available"
      end
    end

    def hesa_record_last_changed_at
      trainee.hesa_updated_at&.iso8601
    end

    def itt_start_date
      trainee.itt_start_date&.iso8601
    end

    def last_names
      trainee.last_name
    end

    def lead_partner_name
      trainee.lead_partner_not_applicable? ? I18n.t(:not_applicable) : trainee.lead_partner&.name
    end

    def lead_partner_urn
      trainee.lead_partner&.urn
    end

    def nationality
      trainee.nationalities.pluck(:name).map(&:titleize).join(", ")
    end

    def number_of_degrees
      trainee.degrees.size
    end

    def provider_id
      trainee.provider&.code
    end

    def provider_name
      trainee.provider&.name
    end

    def record_created_at
      trainee.created_at&.iso8601
    end

    def record_source
      {
        "manual" => "Manual",
        "apply" => "Apply",
        "dttp" => "DTTP",
        "hesa" => "HESA",
        "csv" => "CSV",
        "api" => "API",
      }[trainee.derived_record_source]
    end

    def register_id
      trainee.slug
    end

    def register_record_last_changed_at
      trainee.updated_at&.iso8601
    end

    def return_from_deferral_date
      trainee.reinstate_date&.iso8601
    end

    def sex
      return if trainee.sex.blank?

      I18n.t("components.confirmation.personal_detail.sexes.#{trainee.sex}")
    end

    def start_academic_year
      trainee.start_academic_cycle&.label
    end

    def submitted_for_trn_at
      trainee.submitted_for_trn_at&.iso8601
    end

    def completed = trainee.submission_ready?

    def trainee_start_date
      trainee.trainee_start_date&.iso8601
    end

    def trainee_status
      StatusTag::View.new(trainee:).status
    end

    def trainee_url
      "#{Settings.base_url}/trainees/#{trainee.slug}"
    end

    def training_initiative
      return if trainee.training_initiative.blank?

      I18n.t("activerecord.attributes.trainee.training_initiatives.#{trainee.training_initiative}")
    end

    def withdraw_date
      trainee.withdraw_date&.to_date&.iso8601
    end

    def qts_or_eyts
      trainee.award_type
    end

    def withdraw_reasons
      trainee.withdrawal_reasons.map do |reason|
        I18n.t("components.withdrawal_details.reasons.#{reason.name}")
      end.join("\n")
    end

    def course_age_range
      return nil if course_minimum_age.blank? && course_maximum_age.blank?

      "#{course_minimum_age} to #{course_maximum_age}"
    end

    def hesa_id
      trainee.hesa_id&.starts_with?("'") ? trainee.hesa_id : trainee.hesa_id&.prepend("'") # prevent Excel from converting it to scientific notation
    end

    def sanitised_hesa_id
      trainee.hesa_id&.gsub(/[^\d]/, "")
    end

  private

    def placements
      @placements ||= PlacementsImportedFromHesa.call(trainee:) ? trainee.placements.reverse : trainee.placements
    end
  end
end
