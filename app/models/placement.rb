# frozen_string_literal: true

# == Schema Information
#
# Table name: placements
#
#  id         :bigint           not null, primary key
#  address    :text
#  name       :string
#  postcode   :string
#  urn        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint
#  trainee_id :bigint
#
# Indexes
#
#  index_placements_on_school_id   (school_id)
#  index_placements_on_trainee_id  (trainee_id)
#
class Placement < ApplicationRecord
  belongs_to :trainee, touch: true
  belongs_to :school, touch: true, optional: true

  validates :name, presence: true, if: -> { school.blank? }

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
end
