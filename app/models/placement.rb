# frozen_string_literal: true

# == Schema Information
#
# Table name: placements
#
#  id         :bigint           not null, primary key
#  address    :text
#  name       :string
#  postcode   :string
#  slug       :citext
#  urn        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint
#  trainee_id :bigint
#
# Indexes
#
#  index_placements_on_school_id                            (school_id)
#  index_placements_on_slug_and_trainee_id                  (slug,trainee_id) UNIQUE
#  index_placements_on_trainee_id                           (trainee_id)
#  index_placements_on_trainee_id_and_address_and_postcode  (trainee_id,address,postcode) UNIQUE WHERE (school_id IS NULL)
#  index_placements_on_trainee_id_and_urn                   (trainee_id,urn) UNIQUE WHERE ((urn IS NOT NULL) AND ((urn)::text <> ''::text) AND (school_id IS NULL))
#
class Placement < ApplicationRecord
  include Sluggable

  attr_accessor :school_search
  default_scope { order(created_at: :asc) }

  belongs_to :trainee
  belongs_to :school, optional: true

  validates :name, presence: true, if: -> { school.blank? }
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :school, uniqueness: { scope: :trainee_id }, allow_blank: true
  # rubocop:enable Rails/UniqueValidationWithoutIndex
  validates :urn, uniqueness: { scope: :trainee_id }, allow_blank: true
  validates :address, uniqueness: { scope: %i[trainee_id postcode] }, allow_blank: true

  audited associated_with: :trainee

  scope :with_urn, -> { where.not(urn: nil) }

  def name
    school&.name || super
  end

  def full_address
    return if Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS.include?(urn)

    full_address = if school.blank?
                     parts = [address, postcode].compact

                     urn.present? ? parts.unshift("URN #{urn}") : parts
                   else
                     ["URN #{school.urn}", school.town, school.postcode]
                   end

    full_address.join(", ")
  end

  def created_by_hesa?
    audits.exists?(action: "create", username: Trainees::CreateFromHesa::USERNAME)
  end
end
