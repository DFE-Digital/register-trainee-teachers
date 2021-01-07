# frozen_string_literal: true

class Trainee < ApplicationRecord
  include PgSearch::Model

  belongs_to :provider
  has_many :degrees, dependent: :destroy
  has_many :nationalisations, dependent: :destroy, inverse_of: :trainee
  has_many :nationalities, through: :nationalisations
  has_many :trainee_disabilities, dependent: :destroy, inverse_of: :trainee
  has_many :disabilities, through: :trainee_disabilities

  attribute :progress, Progress.to_type

  validates :record_type, presence: { message: "You must select a route" }
  validates :trainee_id, length: { maximum: 100, message: "Your entry must not exceed 100 characters" }

  enum record_type: { assessment_only: 0, provider_led: 1 }
  enum locale_code: { uk: 0, non_uk: 1 }
  enum gender: {
    male: 0,
    female: 1,
    other: 2,
    gender_not_provided: 3,
  }

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

  enum withdraw_reason: {
    WithdrawalReasons::UNKNOWN => 0,
    WithdrawalReasons::FOR_ANOTHER_REASON => 1,
    WithdrawalReasons::DEATH => 2,
    WithdrawalReasons::EXCLUSION => 3,
    WithdrawalReasons::FINANCIAL_REASONS => 4,
    WithdrawalReasons::GONE_INTO_EMPLOYMENT => 5,
    WithdrawalReasons::HEALTH_REASONS => 6,
    WithdrawalReasons::PERSONAL_REASONS => 7,
    WithdrawalReasons::TRANSFERRED_TO_ANOTHER_PROVIDER => 8,
    WithdrawalReasons::WRITTEN_OFF_AFTER_LAPSE_OF_TIME => 9,
  }

  enum state: {
    draft: 0,
    submitted_for_trn: 1,
    trn_received: 2,
    recommended_for_qts: 3,
    withdrawn: 4,
    deferred: 5,
    qts_awarded: 6,
  }

  enum age_range: {
    AgeRange::THREE_TO_ELEVEN_PROGRAMME => 0,
    AgeRange::FIVE_TO_ELEVEN_PROGRAMME => 1,
    AgeRange::ELEVEN_TO_SIXTEEN_PROGRAMME => 2,
    AgeRange::ELEVEN_TO_NINETEEN_PROGRAMME => 3,
    AgeRange::ZERO_TO_FIVE_PROGRAMME => 4,
    AgeRange::THREE_TO_SEVEN_PROGRAMME => 5,
    AgeRange::THREE_TO_EIGHT_PROGRAMME => 6,
    AgeRange::THREE_TO_NINE_PROGRAMME => 7,
    AgeRange::FIVE_TO_NINE_PROGRAMME => 8,
    AgeRange::FIVE_TO_FOURTEEN_PROGRAMME => 9,
    AgeRange::SEVEN_TO_ELEVEN_PROGRAMME => 10,
    AgeRange::SEVEN_TO_FOURTEEN_PROGRAMME => 11,
    AgeRange::SEVEN_TO_SIXTEEN_PROGRAMME => 12,
    AgeRange::NINE_TO_FOURTEEN_PROGRAMME => 13,
    AgeRange::NINE_TO_SIXTEEN_PROGRAMME => 14,
    AgeRange::FOURTEEN_TO_NINETEEN_PROGRAMME => 15,
    AgeRange::FOURTEEN_TO_NINETEEN_DIPLOMA => 16,
  }

  pg_search_scope :with_name_trainee_id_or_trn_like,
                  against: %i[first_names middle_names last_name trainee_id trn],
                  using: { tsearch: { prefix: true } }

  scope :ordered_by_date, -> { order(updated_at: :desc) }
  scope :is_draft, -> { where(state: "draft") }
  scope :is_not_draft, -> { where.not(state: "draft") }

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
