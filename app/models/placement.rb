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

  # A school or setting that is not listed is given a full address. The lines
  # are kept in the `address` column, one per line, in this order, so that a
  # blank second line keeps its place.
  ADDRESS_LINE_FIELDS = %i[address_line_one address_line_two town_city].freeze
  ADDRESS_LINE_SEPARATOR = "\n"

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

  def self.address_from_lines(*lines)
    lines = lines.map { |line| line.to_s.squish }
    return if lines.all?(&:blank?)

    lines.join(ADDRESS_LINE_SEPARATOR)
  end

  def self.split_address(address)
    address.to_s.split(ADDRESS_LINE_SEPARATOR, ADDRESS_LINE_FIELDS.size)
  end

  def address_lines
    self.class.split_address(address).compact_blank
  end

  def full_address
    return if School::NOT_APPLICABLE_SCHOOL_URNS.include?(urn)

    full_address = if school.blank?
                     parts = [*address_lines, postcode].compact_blank

                     urn.present? ? parts.unshift("URN #{urn}") : parts
                   else
                     ["URN #{school.urn}", school.town, school.postcode]
                   end

    full_address.join(", ").presence
  end

  def created_by_hesa?
    audits.exists?(action: "create", username: User::HESA_USERNAME)
  end
end
