# frozen_string_literal: true

class Trainee < ApplicationRecord
  belongs_to :provider

  attribute :progress, Progress.to_type

  validates :record_type, presence: { message: "You must select a route" }
  validates :trainee_id, length: { maximum: 100, message: "Your entry must not exceed 100 characters" }

  enum record_type: { assessment_only: 0 }
  enum locale_code: { uk: 0, non_uk: 1 }
  enum gender: { male: 0, female: 1, other: 2 }

  enum diversity_disclosure: {
    Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] => 0,
    Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] => 1,
  }

  enum disability_disclosure: {
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] => 0,
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_disabled] => 1,
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] => 2,
  }

  enum ethnic_group: {
    Diversities::ETHNIC_GROUP_ENUMS[:asian] => 0,
    Diversities::ETHNIC_GROUP_ENUMS[:black] => 1,
    Diversities::ETHNIC_GROUP_ENUMS[:mixed] => 2,
    Diversities::ETHNIC_GROUP_ENUMS[:white] => 3,
    Diversities::ETHNIC_GROUP_ENUMS[:other] => 4,
    Diversities::ETHNIC_GROUP_ENUMS[:not_provided] => 5,
  }

  belongs_to :provider
  has_many :degrees, dependent: :destroy
  has_many :nationalisations, dependent: :destroy, inverse_of: :trainee
  has_many :nationalities, through: :nationalisations
  has_many :trainee_disabilities, dependent: :destroy, inverse_of: :trainee
  has_many :disabilities, through: :trainee_disabilities

  def dttp_id=(value)
    raise LockedAttributeError, "dttp_id update failed for trainee ID: #{id}, with value: #{value}" if dttp_id.present?

    super
  end

  def assign_contact_details(params)
    if params[:locale_code] == "uk"
      assign_attributes(params.merge(international_address: nil))
    else
      assign_attributes(params.merge(address_line_one: nil, address_line_two: nil, town_city: nil, postcode: nil))
    end
  end
end
