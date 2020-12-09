# frozen_string_literal: true

class PersonalDetail
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

  attr_accessor(*FIELDS, :trainee, :day, :month, :year)

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
      nationality_ids: nationalities,
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
        fields.except(:day, :month, :year).symbolize_keys.merge(
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

  def nationalities
    return trainee.nationality_ids if attributes[:nationality_ids].blank?

    attributes[:nationality_ids].reject(&:blank?).map(&:to_i)
  end

  def date_of_birth_valid
    errors.add(:date_of_birth, :invalid) unless date_of_birth.is_a?(Date)
  end

  def date_of_birth_not_in_future
    errors.add(:date_of_birth, :future) if date_of_birth.is_a?(Date) && date_of_birth > Time.zone.today
  end

  def nationalities_cannot_be_empty
    return unless nationalities.empty?

    errors.add(:nationality_ids, :empty_nationalities)
  end
end
