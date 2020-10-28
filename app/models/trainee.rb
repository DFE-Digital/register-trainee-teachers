class Trainee < ApplicationRecord
  validates :record_type, presence: { message: "You must select a route" }
  validates :trainee_id, length: { maximum: 100, message: "Your entry must not exceed 100 characters" }

  enum record_type: { assessment_only: 0 }
  enum locale_code: { uk: 0, non_uk: 1 }
  enum diversity_disclosure: { yes: 0, no: 1 }
  enum gender: { male: 0, female: 1, other: 2 }
  enum ethnic_group: {
    Diversities::ENUMS[:asian] => 0,
    Diversities::ENUMS[:black] => 1,
    Diversities::ENUMS[:mixed] => 2,
    Diversities::ENUMS[:white] => 3,
    Diversities::ENUMS[:other] => 4,
    Diversities::ENUMS[:not_provided] => 5,
  }

  has_many :degrees, dependent: :destroy
  has_many :nationalisations, dependent: :destroy, inverse_of: :trainee
  has_many :nationalities, through: :nationalisations

  def dttp_id=(value)
    raise LockedAttributeError, "dttp_id update failed for trainee ID: #{id}, with value: #{value}" if dttp_id.present?

    super
  end
end
