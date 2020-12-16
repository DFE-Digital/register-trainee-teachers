# frozen_string_literal: true

class PersonalDetailForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %w[
    first_names
    middle_names
    last_name
    gender
    nationality_ids
  ].freeze

  delegate :id, :persisted?, to: :trainee

  attr_accessor(*FIELDS, :trainee, :day, :month, :year, :other_nationality1,
                :other_nationality2, :other_nationality3, :other)

  validates :first_names, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true, inclusion: { in: Trainee.genders.keys }

  validate :date_of_birth_valid
  validate :date_of_birth_not_in_future
  validate :nationalities_cannot_be_empty

  after_validation :update_trainee_attributes

  def initialize(trainee, attributes = {})
    @trainee = trainee
    @attributes = attributes
    super(fields)
  end

  def fields
    trainee.attributes.merge(attributes).slice(*FIELDS).merge(
      nationality_ids: trainee.nationality_ids,
      # Check for `other_is_selected?` needed for 'blank' error styling. In this case,
      # it needs to be expanded, but there are no 'other' nationalities on the trainee.
      other: other_is_selected? || other_nationalities_hash.values.any?,
      **other_nationalities_hash,
      **date_of_birth_hash,
    )
  end

  def date_of_birth
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    if Date.valid_date?(*date_args)
      Date.new(*date_args)
    else
      Struct.new(*date_hash.keys).new(*date_hash.values)
    end
  end

  def save
    valid? && trainee.save
  end

private

  attr_reader :attributes

  def update_trainee_attributes
    if errors.empty?
      trainee.assign_attributes(
        fields.except(
          :day, :month, :year, :other, :other_nationality1, :other_nationality2,
          :other_nationality3
        ).symbolize_keys
        .merge(
          date_of_birth: date_of_birth,
          nationality_ids: nationalities,
        ),
      )
    end
  end

  def date_of_birth_hash
    {
      day: trainee.date_of_birth&.day,
      month: trainee.date_of_birth&.month,
      year: trainee.date_of_birth&.year,
    }.merge(attributes.slice(:day, :month, :year).to_h.symbolize_keys)
  end

  def other_nationalities_hash
    # Re-hydrate the 'Other nationality' fields from the trainee model.
    nationality1, nationality2, nationality3 = trainee.nationalities
      .where.not(name: %w[british irish]).pluck(:id)

    {
      other_nationality1: nationality1,
      other_nationality2: nationality2,
      other_nationality3: nationality3,
    }
  end

  def nationalities
    return trainee.nationality_ids if attributes[:nationality_ids].blank?

    nationalities = attributes[:nationality_ids]

    if other_is_selected?
      nationalities += [attributes[:other_nationality1], attributes[:other_nationality2], attributes[:other_nationality3]]
    end

    nationalities&.reject(&:blank?)&.uniq&.map(&:to_i)
  end

  def date_of_birth_valid
    errors.add(:date_of_birth, :invalid) unless date_of_birth.is_a?(Date)
  end

  def date_of_birth_not_in_future
    errors.add(:date_of_birth, :future) if date_of_birth.is_a?(Date) && date_of_birth > Time.zone.today
  end

  def other_is_selected?
    ActiveModel::Type::Boolean.new.cast(attributes[:other])
  end

  def nationalities_cannot_be_empty
    if nationalities.empty?
      errors.add(:nationality_ids, :empty_nationalities)
    end

    if other_is_selected? && attributes[:other_nationality1].blank?
      errors.add(:other_nationality1, :blank)
    end
  end
end
