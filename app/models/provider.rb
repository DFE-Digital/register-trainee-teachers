# frozen_string_literal: true

# == Schema Information
#
# Table name: providers
#
#  id                 :bigint           not null, primary key
#  apply_sync_enabled :boolean          default(FALSE)
#  code               :string
#  name               :string           not null
#  ukprn              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  accreditation_id   :string
#  dttp_id            :uuid
#
# Indexes
#
#  index_providers_on_accreditation_id  (accreditation_id) UNIQUE
#  index_providers_on_dttp_id           (dttp_id) UNIQUE
#
class Provider < ApplicationRecord
  has_many :provider_users, inverse_of: :provider
  has_many :users, through: :provider_users
  has_many :trainees

  has_many :recommendations_uploads, class_name: "BulkUpdate::RecommendationsUpload"
  has_many :recommendations_upload_rows, class_name: "BulkUpdate::RecommendationsUploadRow", through: :recommendations_uploads

  validates :name, presence: true
  validates :dttp_id, uniqueness: true, format: { with: /\A[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}\z/i }
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

  audited

  has_associated_audits

  before_update :update_courses, if: :code_changed?

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

private

  def update_courses
    Course.where(accredited_body_code: code_was).update_all(accredited_body_code: code)
  end
end
