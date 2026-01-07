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
#  index_placements_on_school_id            (school_id)
#  index_placements_on_slug_and_trainee_id  (slug,trainee_id) UNIQUE
#  index_placements_on_trainee_id           (trainee_id)
#
class Placement < ApplicationRecord
  include Sluggable

  attr_accessor :school_search
  default_scope { order(created_at: :asc) }

  belongs_to :trainee
  belongs_to :school, optional: true

  validates :name, presence: true, if: -> { school.blank? }

  audited associated_with: :trainee

  scope :with_urn, -> { where.not(urn: nil) }
  scope :with_school, -> { joins(:school) }

  def name
    school&.name || super
  end

  def urn
    school&.urn || super
  end

  def postcode
    school&.postcode || super
  end

  def full_address
    return if School::NOT_APPLICABLE_SCHOOL_URNS.include?(urn)

    full_address = if school.blank?
                     parts = [address, postcode].compact

                     urn.present? ? parts.unshift("URN #{urn}") : parts
                   else
                     ["URN #{school.urn}", school.town, school.postcode]
                   end

    full_address.join(", ").presence
  end

  def created_by_hesa?
    audits.exists?(action: "create", username: Trainee::HESA_USERNAME)
  end
end
