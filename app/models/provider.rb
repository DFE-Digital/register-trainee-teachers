# frozen_string_literal: true

# == Schema Information
#
# Table name: providers
#
#  id                 :bigint           not null, primary key
#  accredited         :boolean          default(TRUE), not null
#  apply_sync_enabled :boolean          default(FALSE)
#  code               :string
#  discarded_at       :datetime
#  name               :string           not null
#  searchable         :tsvector
#  ukprn              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  accreditation_id   :string
#  dttp_id            :uuid
#
# Indexes
#
#  index_providers_on_accreditation_id  (accreditation_id) UNIQUE
#  index_providers_on_discarded_at      (discarded_at)
#  index_providers_on_dttp_id           (dttp_id) UNIQUE
#  index_providers_on_searchable        (searchable) USING gin
#
class Provider < ApplicationRecord
  include Discard::Model
  include PgSearch::Model

  has_many :provider_users, inverse_of: :provider
  has_many :users, through: :provider_users
  has_many :trainees

  has_many :recommendations_uploads, class_name: "BulkUpdate::RecommendationsUpload"
  has_many :recommendations_upload_rows, class_name: "BulkUpdate::RecommendationsUploadRow", through: :recommendations_uploads

  validates :name, presence: true
  validates :dttp_id, uniqueness: true, format: { with: /\A[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}\z/i }, allow_blank: true
  validates :code, format: { with: /\A[A-Z0-9]+\z/i }, allow_blank: true
  validates :ukprn, format: { with: /\A[0-9]{8}\z/ }
  validates :accreditation_id, presence: true, uniqueness: true

  has_many :courses,
           class_name: "Course",
           foreign_key: :accredited_body_code,
           primary_key: :code,
           inverse_of: :provider

  has_many :apply_applications, ->(provider) { unscope(:where).where(accredited_body_code: provider.code) }

  has_many :dttp_trainees,
           class_name: "Dttp::Trainee",
           foreign_key: :provider_dttp_id,
           primary_key: :dttp_id,
           inverse_of: :provider

  has_many :funding_payment_schedules, class_name: "Funding::PaymentSchedule", as: :payable
  has_many :funding_trainee_summaries, class_name: "Funding::TraineeSummary", as: :payable

  has_many :bulk_update_trainee_uploads, class_name: "BulkUpdate::TraineeUpload"

  has_many :sign_offs

  audited

  has_associated_audits

  before_save :update_searchable

  before_update :update_courses, if: :code_changed?

  pg_search_scope :search,
                  against: %i[name code ukprn],
                  using: {
                    tsearch: {
                      prefix: true,
                      tsvector_column: "searchable",
                    },
                  }

  scope :active_hei, -> { kept.where(accredited: true).where("accreditation_id ~ ?", "^1[0-9]{3}$") }

  TEACH_FIRST_PROVIDER_CODE = "1TF"
  AMBITION_PROVIDER_CODE = "2A2"
  START_MANDATING_PLACEMENT_DATA_CYCLE = 2022
  NIOT_ACCREDITATION_ID = "5728"

  def code=(cde)
    self[:code] = cde.to_s.upcase
  end

  def hpitt_postgrad?
    # TODO: An arbitrary provider set here until we receive a list of teach first providers
    code == TEACH_FIRST_PROVIDER_CODE
  end

  def name_and_code
    "#{name} (#{code})"
  end

  def without_required_placements
    trainees.awarded.or(trainees.in_training)
      .where.not(trn: nil)
      .where(training_route: PLACEMENTS_ROUTES.keys)
      .joins("LEFT JOIN (SELECT trainee_id, COUNT(*) as placement_count FROM placements GROUP BY trainee_id) placements_counts ON placements_counts.trainee_id = trainees.id")
      .where("placements_counts.placement_count < 2 OR placements_counts.placement_count IS NULL")
      .joins(:end_academic_cycle)
      .where(academic_cycles: { id: AcademicCycle.since_year(START_MANDATING_PLACEMENT_DATA_CYCLE).select(:id) })
  end

  def hei?
    accreditation_id&.starts_with?("1") || accreditation_id == NIOT_ACCREDITATION_ID
  end

  def performance_profile_sign_offs
    sign_offs.performance_profile
  end

  def performance_profile_signed_off?
    sign_offs.performance_profile.previous_academic_cycle.exists?
  end

  def performance_profile_awaiting_sign_off?
    !performance_profile_signed_off?
  end

  def census_sign_offs
    sign_offs.census
  end

  def census_signed_off?
    sign_offs.census.current_academic_cycle.exists?
  end

  def census_awaiting_sign_off?
    !census_signed_off?
  end

private

  def update_courses
    Course.where(accredited_body_code: code_was).update_all(accredited_body_code: code)
  end

  def update_searchable
    ts_vector_value = [
      code,
      name,
      name_normalised,
      ukprn,
    ].join(" ")

    to_tsvector = Arel::Nodes::NamedFunction.new(
      "TO_TSVECTOR", [
        Arel::Nodes::Quoted.new("pg_catalog.simple"),
        Arel::Nodes::Quoted.new(ts_vector_value),
      ]
    )

    self.searchable =
      ActiveRecord::Base
        .connection
        .execute(Arel::SelectManager.new.project(to_tsvector).to_sql)
        .first
        .values
        .first
  end

  def name_normalised
    ReplaceAbbreviation.call(string: StripPunctuation.call(string: name))
  end
end
