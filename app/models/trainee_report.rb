# frozen_string_literal: true

# == Schema Information
#
# Table name: trainee_reports
#
#  id                             :bigint           primary key
#  additional_ethnic_background   :text
#  address_line_1                 :text
#  address_line_2                 :text
#  apply_application              :boolean
#  applying_for_bursary           :boolean
#  applying_for_grant             :boolean
#  applying_for_scholarship       :boolean
#  awarded_at                     :datetime
#  course_full_or_part_time       :integer
#  course_itt_subject_1           :text
#  course_itt_subject_2           :text
#  course_itt_subject_3           :text
#  course_level_from_courses      :integer
#  course_maximum_age             :integer
#  course_minimum_age             :integer
#  course_subject_one             :text
#  course_subjects_names_as_array :string           is an Array
#  created_from_dttp              :boolean
#  degree_1_awarding_institution  :string
#  degree_1_country               :string
#  degree_1_grade                 :string
#  degree_1_graduation_year       :integer
#  degree_1_other_grade           :text
#  degree_1_subject               :string
#  degree_1_type_non_uk           :string
#  degree_1_type_uk               :string
#  degree_1_uk_or_non_uk          :text
#  degrees_as_json                :jsonb
#  disabilities_as_array          :string           is an Array
#  email_address                  :text
#  employing_school_name          :string
#  employing_school_urn           :string
#  ethnic_background              :text
#  first_names                    :text
#  hesa_record                    :boolean
#  hesa_updated_at                :datetime
#  itt_end_date                   :date
#  last_names                     :text
#  lead_school_name               :string
#  lead_school_urn                :string
#  middle_names                   :text
#  nationality_as_array           :string           is an Array
#  number_of_degrees              :bigint
#  other_placements_as_array      :string           is an Array
#  outcome_date                   :date
#  placement_one                  :string
#  placement_two                  :string
#  postcode                       :text
#  provider_name                  :string
#  record_source                  :string
#  reinstate_date                 :date
#  return_from_deferral_date      :date
#  state                          :integer
#  town_city                      :text
#  trainee_bursary_tier           :integer
#  trainee_course_education_phase :integer
#  trainee_date_of_birth          :date
#  trainee_defer_date             :date
#  trainee_disability_disclosure  :integer
#  trainee_diversity_disclosure   :integer
#  trainee_ethnic_group           :integer
#  trainee_international_address  :text
#  trainee_itt_start_date         :date
#  trainee_sex                    :integer
#  trainee_submitted_for_trn_at   :datetime
#  trainee_trainee_start_date     :date
#  trainee_training_initiative    :integer
#  trainee_withdraw_date          :datetime
#  training_route                 :integer
#  trn                            :string
#  withdraw_reasons_as_array      :string           is an Array
#  withdraw_reasons_details       :string
#  withdraw_reasons_dfe_details   :string
#  created_at                     :datetime
#  updated_at                     :datetime
#  apply_id                       :integer
#  course_allocation_subject_id   :bigint
#  end_academic_cycle_id          :bigint
#  hesa_id                        :string
#  provider_id                    :string
#  provider_trainee_id            :text
#  register_id                    :citext
#  start_academic_cycle_id        :bigint
#
# Indexes
#
#  index_trainee_reports_on_id  (id) UNIQUE
#
class TraineeReport < ApplicationRecord
  self.primary_key = :id

  def readonly?
    true
  end

  belongs_to :start_academic_cycle, optional: true, class_name: "AcademicCycle"
  belongs_to :end_academic_cycle, optional: true, class_name: "AcademicCycle"

  belongs_to :course_allocation_subject, optional: true, class_name: "AllocationSubject"

  enum training_route: TRAINING_ROUTES

  enum trainee_training_initiative: ROUTE_INITIATIVES

  enum trainee_bursary_tier: BURSARY_TIERS

  enum trainee_sex: {
    male: 0,
    female: 1,
    other: 2,
    sex_not_provided: 3,
    prefer_not_to_say: 4,
  }

  enum trainee_diversity_disclosure: {
    Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] => 0,
    Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] => 1,
  }

  enum trainee_disability_disclosure: {
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] => 0,
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] => 1,
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] => 2,
  }

  enum trainee_ethnic_group: {
    Diversities::ETHNIC_GROUP_ENUMS[:asian] => 0,
    Diversities::ETHNIC_GROUP_ENUMS[:black] => 1,
    Diversities::ETHNIC_GROUP_ENUMS[:mixed] => 2,
    Diversities::ETHNIC_GROUP_ENUMS[:white] => 3,
    Diversities::ETHNIC_GROUP_ENUMS[:other] => 4,
    Diversities::ETHNIC_GROUP_ENUMS[:not_provided] => 5,
  }

  enum study_mode: TRAINEE_STUDY_MODE_ENUMS

  enum trainee_course_education_phase: {
    COURSE_EDUCATION_PHASE_ENUMS[:primary] => 0,
    COURSE_EDUCATION_PHASE_ENUMS[:secondary] => 1,
    COURSE_EDUCATION_PHASE_ENUMS[:early_years] => 2,
  }

  enum state: {
    draft: 0,
    submitted_for_trn: 1,
    trn_received: 2,
    recommended_for_award: 3,
    withdrawn: 4,
    deferred: 5,
    awarded: 6,
  }

  enum course_level_from_courses: {
    COURSE_EDUCATION_PHASE_ENUMS[:primary] => 0,
    COURSE_EDUCATION_PHASE_ENUMS[:secondary] => 1,
  }, _suffix: true

  def trainee_url
    "#{Settings.base_url}/trainees/#{trainee.register_id}"
  end

  def record_source
    {
      "manual" => "Manual",
      "apply" => "Apply",
      "dttp" => "DTTP",
      "hesa" => "HESA",
    }[trainee.derived_record_source]
  end

  def trainee_status
    {
      submitted_for_trn: "pending trn",
      recommended_for_award: "#{trainee.award_type} recommended",
      awarded: "#{trainee.award_type} awarded",
    }[trainee.state.to_sym] || trainee.state.gsub("_", " ")
  end

  def start_academic_year
    trainee.start_academic_cycle&.label
  end

  def end_academic_year
    trainee.end_academic_cycle&.label
  end

  def academic_years
    return unless trainee.start_academic_cycle && trainee.end_academic_cycle

    start_years = trainee.start_academic_cycle.start_year..trainee.end_academic_cycle.start_year

    start_years.map { |year| "#{year} to #{year + 1}" }.join(", ")
  end

  def record_created_at
    trainee.created_at&.iso8601
  end

  def register_record_last_changed_at
    trainee.updated_at&.iso8601
  end

  def hesa_record_last_changed_at
    trainee.hesa_updated_at&.iso8601
  end

  def submitted_for_trn_at
    trainee_submitted_for_trn_at&.iso8601
  end

  def date_of_birth
    trainee_date_of_birth&.iso8601
  end

  def sex
    return if trainee_sex.blank?

    I18n.t("components.confirmation.personal_detail.sexes.#{trainee_sex}")
  end

  def nationality
    nationality_as_array&.map(&:titleize)&.join(", ")
  end

  def international_address
    Array(trainee_international_address.to_s.split(/[\r\n,]/)).join(", ").presence
  end

  def diversity_disclosure
    return if trainee_diversity_disclosure.blank?

    trainee_diversity_disclosure == "diversity_disclosed" ? "TRUE" : "FALSE"
  end

  def ethnic_group
    I18n.t("components.confirmation.diversity.ethnic_groups.#{trainee_ethnic_group.presence || 'not_provided_ethnic_group'}")
  end

  def ethnic_background_additional
    trainee.additional_ethnic_background
  end

  def disability_disclosure
    return if trainee_disability_disclosure.blank?

    {
      "disabled" => "Has disabilities",
      "disability_not_provided" => "Not provided",
      "no_disability" => "No disabilities",
    }[trainee_disability_disclosure]
  end

  def disabilities
    disabilities_as_array&.join(",")
  end

  def degrees
    trainee.degrees_as_json&.map do |degree|
      [
        degree_1_uk_or_non_uk,
        degree["institution"],
        degree["country"],
        degree["subject"],
        degree["uk_degree"],
        degree["non_uk_degree"],
        degree["grade"],
        degree["other_grade"],
        degree["graduation_year"],
      ].map { |d| "\"#{d}\"" }.join(", ")
    end&.join(" | ")
  end

  def course_training_route
    I18n.t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
  end

  def course_qualification
    trainee.award_type
  end

  def course_education_phase
    return EARLY_YEARS_ROUTE_NAME_PREFIX.humanize if trainee.early_years_route?

    trainee_course_education_phase&.upcase_first || course_level_from_courses&.capitalize
  end

  def training_route_manager
    @training_route_manager ||= TrainingRouteManager.new(self)
  end

  delegate :award_type,
           :requires_schools?,
           :requires_employing_school?,
           :early_years_route?,
           :undergrad_route?,
           :requires_itt_start_date?,
           :requires_study_mode?,
           :requires_degree?,
           :requires_funding?,
           :requires_iqts_country?,
           to: :training_route_manager

  def course_level
    trainee.undergrad_route? ? "undergrad" : "postgrad"
  end

  def itt_start_date
    trainee_itt_start_date&.iso8601
  end

  def expected_end_date
    return "End date not required by HESA so no data available in Register" if # TODO: move text to translation file
      trainee.itt_end_date.blank? && trainee.hesa_record? && !trainee.awaiting_action?

    trainee.itt_end_date&.iso8601
  end

  def course_duration_in_years
    return unless trainee_itt_start_date && itt_end_date

    ((itt_end_date - trainee_itt_start_date) / 365).ceil
  end

  def trainee_start_date
    trainee.trainee_trainee_start_date&.iso8601
  end

  def training_initiative
    return if trainee_training_initiative.blank?

    I18n.t("activerecord.attributes.trainee.training_initiatives.#{trainee_training_initiative}")
  end

  def funding_manager
    @funding_manager ||= FundingManager.new(trainee)
  end

  def trainee = self

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

  def bursary_tier
    {
      "tier_one" => "Tier 1",
      "tier_two" => "Tier 2",
      "tier_three" => "Tier 3",
    }[trainee_bursary_tier]
  end

  def other_placements
    other_placements_as_array&.join(", ")
  end

  def award_standards_met_date
    trainee.outcome_date&.iso8601
  end

  def award_given_at
    return "Currently no data available in Register" if # TODO: move text to translation file
      trainee.awarded_at.blank? && trainee.hesa_record? && trainee.awarded?

    trainee.awarded_at&.iso8601
  end

  def defer_date
    return "Not required by HESA so no data available in Register" if # TODO: move text to translation file
      trainee_defer_date.blank? && trainee.hesa_record? && trainee.deferred?

    trainee_defer_date&.iso8601
  end

  def return_from_deferral_date
    trainee.reinstate_date&.iso8601
  end

  def withdraw_date
    trainee.trainee_withdraw_date&.to_date&.iso8601
  end

  def withdraw_reasons
    trainee.withdraw_reasons_as_array&.map do |name|
      I18n.t("components.withdrawal_details.reasons.#{name}")
    end&.join("\n")
  end

  def course_subject_category
    trainee_allocation_subject(trainee.course_subject_one) || course_course_allocation_subject
  end

  def trainee_allocation_subject(subject)
    return if subject.blank?

    SubjectSpecialism.find_by("lower(name) = ?", subject.downcase)&.allocation_subject&.name
  end

  def course_subjects_names
    trainee.course_subjects_names_as_array
  end

  def course_course_allocation_subject
    return if course_subjects_names.blank?

    subject = CalculateSubjectSpecialisms.call(subjects: course_subjects_names)
      .values.map(&:first).first

    trainee_allocation_subject(subject)
  end

  def to_csv
    [
      register_id,
      trainee_url,
      record_source,
      apply_id,
      hesa_id,
      provider_trainee_id,
      trn,
      trainee_status,
      start_academic_year,
      end_academic_year,
      academic_years,
      record_created_at,
      register_record_last_changed_at,
      hesa_record_last_changed_at,
      submitted_for_trn_at,
      provider_name,
      provider_id,
      first_names,
      middle_names,
      last_names,
      date_of_birth,
      sex,
      nationality,
      address_line_1,
      address_line_2,
      town_city,
      postcode,
      international_address,
      email_address,
      diversity_disclosure,
      ethnic_group,
      ethnic_background,
      ethnic_background_additional,
      disability_disclosure,
      disabilities,
      number_of_degrees,
      degree_1_uk_or_non_uk,
      degree_1_awarding_institution,
      degree_1_country,
      degree_1_subject,
      degree_1_type_uk,
      degree_1_type_non_uk,
      degree_1_grade,
      degree_1_other_grade,
      degree_1_graduation_year,
      degrees,
      course_training_route,
      course_qualification,
      course_education_phase,
      course_subject_category,
      course_itt_subject_1,
      course_itt_subject_2,
      course_itt_subject_3,
      course_minimum_age,
      course_maximum_age,
      course_full_or_part_time,
      course_level,
      itt_start_date,
      expected_end_date,
      course_duration_in_years,
      trainee_start_date,
      lead_school_name,
      lead_school_urn,
      employing_school_name,
      employing_school_urn,
      training_initiative,
      funding_method,
      funding_value,
      bursary_tier,
      placement_one,
      placement_two,
      other_placements,
      award_standards_met_date,
      award_given_at,
      defer_date,
      return_from_deferral_date,
      withdraw_date,
      withdraw_reasons,
      withdraw_reasons_details,
      withdraw_reasons_dfe_details,
    ].map { |value| CsvValueSanitiser.new(value).sanitise }
  end

  def derived_record_source
    return "hesa" if hesa_record?

    return "apply" if apply_application?

    return "dttp" if  created_from_dttp?

    "manual"
  end

  def awaiting_action?
    COMPLETE_STATES.exclude?(state)
  end

  COMPLETE_STATES = %w[recommended_for_award withdrawn awarded].freeze
end
