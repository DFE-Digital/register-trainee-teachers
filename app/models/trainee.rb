# frozen_string_literal: true

# == Schema Information
#
# Table name: trainees
#
#  id                              :bigint           not null, primary key
#  additional_dttp_data            :jsonb
#  additional_ethnic_background    :text
#  applying_for_bursary            :boolean
#  applying_for_grant              :boolean
#  applying_for_scholarship        :boolean
#  awarded_at                      :datetime
#  bursary_tier                    :integer
#  commencement_status             :integer
#  course_education_phase          :integer
#  course_max_age                  :integer
#  course_min_age                  :integer
#  course_subject_one              :text
#  course_subject_three            :text
#  course_subject_two              :text
#  course_uuid                     :uuid
#  created_from_dttp               :boolean          default(FALSE), not null
#  created_from_hesa               :boolean          default(FALSE), not null
#  date_of_birth                   :date
#  defer_date                      :date
#  defer_reason                    :string
#  disability_disclosure           :integer
#  discarded_at                    :datetime
#  diversity_disclosure            :integer
#  dttp_update_sha                 :string
#  ebacc                           :boolean          default(FALSE)
#  email                           :text
#  employing_school_not_applicable :boolean          default(FALSE)
#  ethnic_background               :text
#  ethnic_group                    :integer
#  first_names                     :text
#  hesa_editable                   :boolean          default(FALSE)
#  hesa_updated_at                 :datetime
#  iqts_country                    :string
#  itt_end_date                    :date
#  itt_start_date                  :date
#  last_name                       :text
#  lead_partner_not_applicable     :boolean          default(FALSE)
#  middle_names                    :text
#  outcome_date                    :date
#  placement_detail                :integer
#  progress                        :jsonb
#  recommended_for_award_at        :datetime
#  record_source                   :string
#  region                          :string
#  reinstate_date                  :date
#  sex                             :integer
#  slug                            :citext           not null
#  slug_sent_to_dqt_at             :datetime
#  state                           :integer          default("draft")
#  study_mode                      :integer
#  submission_ready                :boolean          default(FALSE)
#  submitted_for_trn_at            :datetime
#  trainee_start_date              :date
#  training_initiative             :integer
#  training_route                  :integer
#  trn                             :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  application_choice_id           :integer
#  apply_application_id            :bigint
#  course_allocation_subject_id    :bigint
#  dormancy_dttp_id                :uuid
#  dttp_id                         :uuid
#  employing_school_id             :bigint
#  end_academic_cycle_id           :bigint
#  hesa_id                         :string
#  hesa_trn_submission_id          :bigint
#  lead_partner_id                 :bigint
#  placement_assignment_dttp_id    :uuid
#  provider_id                     :bigint           not null
#  provider_trainee_id             :text
#  start_academic_cycle_id         :bigint
#
# Indexes
#
#  index_trainees_on_apply_application_id                          (apply_application_id)
#  index_trainees_on_course_allocation_subject_id                  (course_allocation_subject_id)
#  index_trainees_on_course_uuid                                   (course_uuid)
#  index_trainees_on_disability_disclosure                         (disability_disclosure)
#  index_trainees_on_discarded_at                                  (discarded_at)
#  index_trainees_on_discarded_at__record_source__provider__state  (discarded_at,record_source,provider_id,state)
#  index_trainees_on_diversity_disclosure                          (diversity_disclosure)
#  index_trainees_on_dttp_id                                       (dttp_id)
#  index_trainees_on_employing_school_id                           (employing_school_id)
#  index_trainees_on_end_academic_cycle_id                         (end_academic_cycle_id)
#  index_trainees_on_ethnic_group                                  (ethnic_group)
#  index_trainees_on_hesa_id                                       (hesa_id)
#  index_trainees_on_hesa_trn_submission_id                        (hesa_trn_submission_id)
#  index_trainees_on_lead_partner_id                               (lead_partner_id)
#  index_trainees_on_placement_detail                              (placement_detail)
#  index_trainees_on_progress                                      (progress) USING gin
#  index_trainees_on_provider_id                                   (provider_id)
#  index_trainees_on_sex                                           (sex)
#  index_trainees_on_slug                                          (slug) UNIQUE
#  index_trainees_on_start_academic_cycle_id                       (start_academic_cycle_id)
#  index_trainees_on_state                                         (state)
#  index_trainees_on_submission_ready                              (submission_ready)
#  index_trainees_on_training_route                                (training_route)
#  index_trainees_on_trn                                           (trn)
#
# Foreign Keys
#
#  fk_rails_...  (apply_application_id => apply_applications.id)
#  fk_rails_...  (course_allocation_subject_id => allocation_subjects.id)
#  fk_rails_...  (employing_school_id => schools.id)
#  fk_rails_...  (end_academic_cycle_id => academic_cycles.id)
#  fk_rails_...  (hesa_trn_submission_id => hesa_trn_submissions.id)
#  fk_rails_...  (lead_partner_id => lead_partners.id)
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (start_academic_cycle_id => academic_cycles.id)
#
class Trainee < ApplicationRecord
  self.ignored_columns += %w[trainee_id]

  include Sluggable
  include Sourceable
  include PgSearch::Model
  include Discard::Model

  include TrainingRouteManageable

  belongs_to :provider
  belongs_to :apply_application, optional: true

  belongs_to :dttp_trainee,
             foreign_key: :dttp_id,
             primary_key: :dttp_id,
             optional: true,
             inverse_of: :trainee,
             class_name: "Dttp::Trainee"

  belongs_to :lead_partner, optional: true
  has_one :lead_partner_school, through: :lead_partner, class_name: "School", source: :school

  belongs_to :employing_school, optional: true, class_name: "School"

  belongs_to :course_allocation_subject, optional: true, class_name: "AllocationSubject"

  belongs_to :published_course,
             ->(trainee) { where(accredited_body_code: trainee.provider.code) },
             foreign_key: :course_uuid,
             primary_key: :uuid,
             inverse_of: :trainees,
             optional: true,
             class_name: "Course"

  belongs_to :start_academic_cycle, optional: true, class_name: "AcademicCycle"
  belongs_to :end_academic_cycle, optional: true, class_name: "AcademicCycle"
  belongs_to :hesa_trn_submission, optional: true, class_name: "Hesa::TrnSubmission"

  has_one :hesa_trainee_detail, class_name: "Hesa::TraineeDetail"
  has_one :hesa_metadatum, class_name: "Hesa::Metadatum"
  has_one :trs_trn_request, class_name: "Trs::TrnRequest", dependent: :destroy

  has_many :degrees, dependent: :destroy
  has_many :nationalisations, dependent: :destroy, inverse_of: :trainee
  has_many :nationalities, through: :nationalisations
  has_many :trainee_disabilities, dependent: :destroy, inverse_of: :trainee
  has_many :disabilities, through: :trainee_disabilities

  has_many :hesa_students,
           foreign_key: :hesa_id,
           primary_key: :hesa_id,
           inverse_of: :trainee,
           class_name: "Hesa::Student"

  has_many :recommendations_upload_rows,
           foreign_key: :matched_trainee_id,
           class_name: "BulkUpdate::RecommendationsUploadRow",
           dependent: :nullify,
           inverse_of: :trainee

  has_many :placements, dependent: :destroy, inverse_of: :trainee

  # This is the old relation which will be retired
  has_many :trainee_withdrawal_reasons, inverse_of: :trainee
  has_many :withdrawal_reasons, through: :trainee_withdrawal_reasons
  # Going forward, withdrawal_reasons belong to a trainee's withdrawal record within "trainee_withdrawals"
  has_many :trainee_withdrawals, dependent: :destroy

  has_many :potential_duplicate_trainees, dependent: :destroy

  attribute :progress, Progress.to_type

  delegate :update_training_route!, to: :route_data_manager
  delegate :date, to: :current_withdrawal, prefix: :withdraw, allow_nil: true

  validates :training_route, presence: {
    message: I18n.t("activerecord.errors.models.trainee.attributes.training_route"),
  }

  enum :training_route, TRAINING_ROUTES

  enum :training_initiative, ROUTE_INITIATIVES

  enum :bursary_tier, BURSARY_TIERS

  enum :sex, {
    male: 0,
    female: 1,
    other: 2,
    sex_not_provided: 3,
    prefer_not_to_say: 4,
  }

  enum :commencement_status, COMMENCEMENT_STATUSES

  enum :placement_detail, {
    PLACEMENT_DETAIL_ENUMS[:has_placement_detail] => 0,
    PLACEMENT_DETAIL_ENUMS[:no_placement_detail] => 1,
  }

  enum :diversity_disclosure, {
    Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] => 0,
    Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] => 1,
  }

  enum :disability_disclosure, {
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] => 0,
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] => 1,
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] => 2,
  }

  enum :ethnic_group, {
    Diversities::ETHNIC_GROUP_ENUMS[:asian] => 0,
    Diversities::ETHNIC_GROUP_ENUMS[:black] => 1,
    Diversities::ETHNIC_GROUP_ENUMS[:mixed] => 2,
    Diversities::ETHNIC_GROUP_ENUMS[:white] => 3,
    Diversities::ETHNIC_GROUP_ENUMS[:other] => 4,
    Diversities::ETHNIC_GROUP_ENUMS[:not_provided] => 5,
  }

  enum :study_mode, ReferenceData::Loader.instance.enum_values_for(:trainee_study_mode)

  enum :course_education_phase, {
    COURSE_EDUCATION_PHASE_ENUMS[:primary] => 0,
    COURSE_EDUCATION_PHASE_ENUMS[:secondary] => 1,
    COURSE_EDUCATION_PHASE_ENUMS[:early_years] => 2,
  }

  enum :state, {
    draft: 0,
    submitted_for_trn: 1,
    trn_received: 2,
    recommended_for_award: 3,
    withdrawn: 4,
    deferred: 5,
    awarded: 6,
  } do
    event :submit_for_trn do
      before do
        self.submitted_for_trn_at = Time.zone.now
        apply_application&.update!(invalid_data: nil)
      end

      transition %i[draft deferred] => :submitted_for_trn
    end

    event :receive_trn do
      transition %i[submitted_for_trn deferred trn_received] => :trn_received
    end

    event :recommend_for_award do
      before do
        self.recommended_for_award_at = Time.zone.now
      end

      transition %i[trn_received] => :recommended_for_award
    end

    event :withdraw do
      transition %i[submitted_for_trn trn_received deferred] => :withdrawn
    end

    event :defer do
      transition %i[submitted_for_trn trn_received] => :deferred
    end

    event :award do
      before do
        raise StateTransitionError, "Cannot transition to :awarded without an awarded_at date" if awarded_at.blank?
      end

      transition %i[recommended_for_award] => :awarded
    end
  end

  COMPLETE_STATES = %w[recommended_for_award withdrawn awarded].freeze
  IN_TRAINING_STATES = %w[submitted_for_trn trn_received recommended_for_award].freeze

  pg_search_scope :with_name_provider_trainee_id_or_trn_like,
                  against: %i[first_names middle_names last_name provider_trainee_id trn],
                  using: { tsearch: { prefix: true } }

  scope :ordered_by_updated_at, -> { order(updated_at: :desc) }
  scope :ordered_by_last_name, -> { order(last_name: :asc) }

  # NOTE: Enforce subquery to remove duplications and allow for chain-ability.
  scope :with_subject_or_allocation_subject, (lambda do |subject|
    where(
      id: distinct.select("trainees.id")
        .joins(join_allocation_subjects_clause)
        .where("LOWER(course_subject_one) = :subject OR LOWER(course_subject_two) = :subject OR LOWER(course_subject_three) = :subject OR LOWER(allocation_subjects.name) = :subject", subject: subject.downcase),
    )
  end)

  scope :course_not_yet_started, -> { where("itt_start_date > ?", Time.zone.now).where.not(state: %i[draft deferred withdrawn]) }

  scope :in_training, -> { where(state: IN_TRAINING_STATES, itt_start_date: Date.new..Time.zone.now) }

  scope :with_apply_application, -> { apply_record }

  # We only look for the HESA ID to determine if a trainee record came from HESA.
  # Even though some records imported from DTTP will have a HESA ID, their original source is HESA so we chose this implementation
  scope :imported_from_hesa, -> { where(record_source: HESA_SOURCES) }

  scope :imported_from_hesa_trn_data, -> { hesa_trn_data_record }

  scope :complete, -> { where(submission_ready: true).or(where(state: COMPLETE_STATES)) }
  scope :incomplete, -> { where(submission_ready: false).where.not(state: COMPLETE_STATES) }

  scope :on_early_years_routes, -> { where(training_route: EARLY_YEARS_TRAINING_ROUTES.keys) }

  scope :with_trn, -> { where.not(trn: nil) }
  scope :without_trn, -> { where(trn: nil) }

  scope :potential_duplicates_of, lambda { |trainee|
    trainee.provider.trainees.kept
      .and(Trainee.not_withdrawn.or(Trainee.not_awarded))
      .where(date_of_birth: trainee.date_of_birth)
      .where("last_name ILIKE ?", trainee.last_name)
      .where("id != ?", trainee.id)
      .where(
        training_route: trainee.training_route,
        start_academic_cycle_id: trainee.start_academic_cycle_id,
      )
  }
  scope :not_marked_as_duplicate, -> { where.not(id: PotentialDuplicateTrainee.select(:trainee_id)) }

  audited associated_with: :provider
  has_associated_audits

  auto_strip_attributes(
    :first_names,
    :middle_names,
    :last_name,
    :email,
    :ethnic_background,
    :additional_ethnic_background,
    :trn,
    :region,
    :hesa_id,
    :course_subject_one,
    :course_subject_two,
    :course_subject_three,
    squish: true,
    nullify: false,
  )

  before_save :clear_employing_school_id, if: :employing_school_not_applicable?
  before_save :clear_lead_partner_id, if: :lead_partner_not_applicable?
  before_save :set_submission_ready, if: :awaiting_action?
  before_save :set_academic_cycles

  after_touch :set_submission_ready

  accepts_nested_attributes_for(
    :trainee_disabilities,
    :trainee_withdrawals,
    :placements,
    :degrees,
  )
  accepts_nested_attributes_for :nationalisations, allow_destroy: true
  accepts_nested_attributes_for :hesa_trainee_detail, update_only: true

  def hesa_student_for_collection(collection_reference)
    Hesa::Student.where(hesa_id:, collection_reference:).order(created_at: :asc).first
  end

  def trn_requested!(dttp_id, placement_assignment_dttp_id)
    update!(dttp_id:, placement_assignment_dttp_id:)
  end

  def trn_received!(new_trn = nil)
    raise(StateTransitionError, "Cannot transition to :trn_received without a trn") unless new_trn || trn

    # Skip deferred and withdrawn to avoid state change but to still register trn
    receive_trn! unless deferred? || withdrawn?

    # A deferred trainee will probably already have a trn - don't overwrite that!
    update!(trn: new_trn) unless trn
  end

  def award_qts!(awarded_at)
    self.awarded_at = awarded_at
    award!
  end

  def dttp_id=(value)
    raise(LockedAttributeError, "dttp_id update failed for trainee ID: #{id}, with value: #{value}") if dttp_id.present?

    super
  end

  def sha
    Digest::SHA1.hexdigest(value_digest)
  end

  def self.join_allocation_subjects_clause
    Arel.sql(<<~SQL)
      LEFT JOIN subject_specialisms AS specialism ON specialism.name = trainees.course_subject_one OR specialism.name = trainees.course_subject_two OR specialism.name = trainees.course_subject_three
      LEFT JOIN allocation_subjects ON specialism.allocation_subject_id = allocation_subjects.id
    SQL
  end

  def available_courses(training_route = self.training_route)
    provider.courses.where(route: training_route).order(:name) if TRAINING_ROUTES_FOR_COURSE.keys.include?(training_route)
  end

  def clear_disabilities
    disabilities.clear
  end

  def apply_application?
    apply_application.present?
  end

  def course_age_range
    [course_min_age, course_max_age].compact
  end

  def course_age_range=(range)
    self.course_min_age, self.course_max_age = range
  end

  def course_subjects
    [course_subject_one, course_subject_two, course_subject_three].compact_blank
  end

  def route_data_manager
    @route_data_manager ||= RouteDataManager.new(trainee: self)
  end

  def self.genericize_state(state)
    if state.end_with?("awarded")
      "awarded"
    elsif state.end_with?("recommended")
      "recommended_for_award"
    else
      state
    end
  end

  def timeline
    Rails.cache.fetch([self, :timeline]) do
      Trainees::CreateTimeline.call(trainee: self)
    end
  end

  def set_early_years_course_details
    if early_years_route?
      course_subject = CourseSubjects::EARLY_YEARS_TEACHING
      self.course_subject_one = course_subject
      self.course_age_range = DfE::ReferenceData::AgeRanges::ZERO_TO_FIVE
      self.course_allocation_subject = SubjectSpecialism.find_by(name: course_subject)&.allocation_subject
      self.course_education_phase = COURSE_EDUCATION_PHASE_ENUMS[:early_years]
    end
  end

  def invalid_apply_data?
    apply_application&.invalid_data.present?
  end

  def hpitt_provider?
    @hpitt_provider ||= provider&.hpitt_postgrad?
  end

  def course_duration_in_years
    return unless itt_start_date && itt_end_date

    ((itt_end_date - itt_start_date) / 365).ceil
  end

  def starts_course_in_the_future?
    itt_start_date&.future?
  end

  def awaiting_action?
    COMPLETE_STATES.exclude?(state)
  end

  def short_name
    [
      first_names,
      last_name,
    ].compact_blank.join(" ").presence
  end

  def inactive?
    if state == "awarded"
      AcademicCycle.for_date(awarded_at) != AcademicCycle.for_date(Time.zone.now)
    else
      state == "withdrawn"
    end
  end

  def full_name
    [
      first_names,
      middle_names,
      last_name,
    ].compact_blank.join(" ").presence
  end

  def duplicate?
    Trainee.where(first_names:, last_name:, date_of_birth:, email:).many?
  end

  def derived_record_source
    case record_source
    when API_SOURCE
      "api"
    when CSV_SOURCE
      "csv"
    when HESA_COLLECTION_SOURCE, HESA_TRN_DATA_SOURCE
      "hesa"
    when APPLY_SOURCE
      "apply"
    when DTTP_SOURCE
      "dttp"
    else
      "manual"
    end
  end

  def estimated_end_date
    start_date + estimated_course_duration
  end

  def start_date
    trainee_start_date || itt_start_date
  end

  def estimated_course_duration
    return 70.months if provider_led_undergrad? && part_time?

    return 34.months if provider_led_undergrad? && full_time?

    return 22.months if opt_in_undergrad? || part_time?

    10.months
  end

  def all_errors
    errors
  end

  def current_withdrawal
    trainee_withdrawals.kept.last
  end

  def current_withdrawal_reasons
    current_withdrawal&.withdrawal_reasons
  end

private

  def value_digest
    # this returns a comma separated string of values from this object and its associations
    # we use this to determine if we need to update DTTP. We use values only and exclude nils to avoid
    # sending updates when we add a field to the schema.

    exclude_list = %w[created_at updated_at dttp_update_sha progress submission_ready]

    trainee_values = serializable_hash.except(*exclude_list).values.compact

    (
      trainee_values + [degrees, nationalities, disabilities].flat_map do |assoc|
        assoc.map(&:serializable_hash).flat_map(&:values).compact
      end
    ).join(",")
  end

  def clear_employing_school_id
    self.employing_school_id = nil
  end

  def clear_lead_partner_id
    self.lead_partner_id = nil
  end

  def set_submission_ready
    # Use the TRN validator when dealing with drafts trainees and if they're also an apply draft.
    # Before trn submission, when invalid_data on an apply application is cleared, the application is
    # updated but not the trainee. The trainee will be set to submitted_for_trn by the transition
    # callbacks, but theoretically still a draft as it has not been saved, so we need to check for this.
    draft_or_just_changed_from_draft = draft? || (state_changed? && state_was == "draft")
    draft_and_apply = draft_or_just_changed_from_draft && apply_application?

    validate_trn = draft_and_apply || draft?

    submission_klass = validate_trn ? Submissions::TrnValidator : Submissions::MissingDataValidator
    self.submission_ready = submission_klass.new(trainee: self).valid?
  end

  def set_academic_cycles
    Trainees::SetAcademicCycles.call(trainee: self)
  end
end
