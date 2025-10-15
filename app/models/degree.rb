# frozen_string_literal: true

# == Schema Information
#
# Table name: degrees
#
#  id               :bigint           not null, primary key
#  country          :string
#  grade            :string
#  grade_uuid       :uuid
#  graduation_year  :integer
#  institution      :string
#  institution_uuid :uuid
#  locale_code      :integer          not null
#  non_uk_degree    :string
#  other_grade      :text
#  slug             :citext           not null
#  subject          :string
#  subject_uuid     :uuid
#  uk_degree        :string
#  uk_degree_uuid   :uuid
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  dttp_id          :uuid
#  trainee_id       :bigint           not null
#
# Indexes
#
#  index_degrees_on_dttp_id      (dttp_id)
#  index_degrees_on_locale_code  (locale_code)
#  index_degrees_on_slug         (slug) UNIQUE
#  index_degrees_on_trainee_id   (trainee_id)
#
# Foreign Keys
#
#  fk_rails_...  (trainee_id => trainees.id)
#
class Degree < ApplicationRecord
  include Sluggable

  MAX_GRAD_YEARS = 60

  attr_writer :is_apply_import

  validates :locale_code, presence: true
  with_options unless: :apply_import? do
    validates :institution, presence: true, on: :uk
    validates :country, presence: true, on: :non_uk
    validates :subject, presence: true, on: %i[uk non_uk]
    validates :uk_degree, presence: true, on: :uk
    validates :non_uk_degree, presence: true, on: :non_uk
    validates :grade, presence: true, on: :uk
    validates :graduation_year, presence: true, on: %i[uk non_uk]
  end

  validates :graduation_year, "degrees/graduation_year": true

  belongs_to :trainee, touch: true

  enum :locale_code, { uk: 0, non_uk: 1 }

  audited associated_with: :trainee

  default_scope { order(graduation_year: :asc) }

  auto_strip_attributes(
    :subject,
    :institution,
    :grade,
    :country,
    :other_grade,
    squish: true,
    nullify: false,
  )

  def non_uk_degree_non_enic?
    non_uk_degree == NON_ENIC
  end

  # other_grade should be nil if grade isn't 'Other'
  def other_grade
    if grade == "Other"
      self[:other_grade]
    end
  end

  def apply_import?
    ActiveModel::Type::Boolean.new.cast(@is_apply_import)
  end
end
