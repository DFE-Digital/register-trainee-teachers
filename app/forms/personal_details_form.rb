# frozen_string_literal: true

class PersonalDetailsForm < TraineeForm
  FIELDS = %i[
    first_names
    middle_names
    last_name
    gender
    nationality_names
    nationality_ids
  ].freeze

  NATIONALITY_FIELD_MAPPINGS = {
    other_nationality1_raw: :other_nationality1,
    other_nationality2_raw: :other_nationality2,
    other_nationality3_raw: :other_nationality3,
  }.freeze

  attr_accessor(*FIELDS, :day, :month, :year, :other_nationality1,
                :other_nationality1_raw, :other_nationality2,
                :other_nationality2_raw, :other_nationality3,
                :other_nationality3_raw, :other)

  validates :first_names, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validate :date_of_birth_valid
  validate :date_of_birth_not_in_future
  validates :gender, presence: true, inclusion: { in: Trainee.genders.keys }
  validate :check_raw_values
  validates :other_nationality1, :other_nationality2, :other_nationality3, autocomplete: true, allow_nil: true
  validate :nationalities_cannot_be_empty

  def date_of_birth
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    Date.valid_date?(*date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

  def save!
    if valid?
      update_trainee_attributes
      trainee.save!
      clear_stash
    else
      false
    end
  end

  def nationality_names
    return @_nationality_names if defined?(@_nationality_names)

    @_nationality_names = nationality_ids.map { |id| Nationality.find(id).name.titleize }
  end

  def nationality_ids
    return @_nationality_ids if defined?(@_nationality_ids)

    @_nationality_ids =
      begin
        reset_blank_nationalities

        if new_attributes[:nationality_names].blank?
          trainee.nationality_ids
        else
          nationalities = new_attributes[:nationality_names]

          if other_is_selected?
            nationalities += [
              new_attributes[:other_nationality1],
              new_attributes[:other_nationality2],
              new_attributes[:other_nationality3],
            ]
          end

          nationalities.reject(&:blank?)
            .map { |name| Nationality.find_by_name(name.downcase)&.id }.uniq
        end
      end
  end

private

  def compute_fields
    trainee.attributes
           .symbolize_keys
           .slice(*FIELDS)
           .merge(new_attributes)
           .merge(nationality_ids: nationality_ids, other: calculate_other, **date_of_birth_hash)
           .reverse_merge(other_nationalities_hash)
  end

  def update_trainee_attributes
    if errors.empty?
      trainee.assign_attributes(
        fields.except(
          :day, :month, :year, :other, :other_nationality1, :other_nationality2, :other_nationality3,
          :other_nationality1_raw, :other_nationality2_raw, :other_nationality3_raw, :nationality_names
        ).merge(
          date_of_birth: date_of_birth, nationality_ids: nationality_ids,
        ),
      )
    end
  end

  def date_of_birth_hash
    {
      day: trainee.date_of_birth&.day,
      month: trainee.date_of_birth&.month,
      year: trainee.date_of_birth&.year,
    }.merge(new_attributes.slice(:day, :month, :year))
  end

  def other_nationalities_hash
    # Re-hydrate the 'Other nationality' fields from the trainee model.
    nationality1, nationality2, nationality3 = trainee.nationalities.where.not(name: %w[british irish]).pluck(:name).map(&:titleize)

    {
      other_nationality1: nationality1,
      other_nationality2: nationality2,
      other_nationality3: nationality3,
    }
  end

  def date_of_birth_valid
    errors.add(:date_of_birth, :invalid) unless date_of_birth.is_a?(Date)
  end

  def date_of_birth_not_in_future
    errors.add(:date_of_birth, :future) if date_of_birth.is_a?(Date) && date_of_birth > Time.zone.today
  end

  def calculate_other
    if new_attributes.present?
      ActiveModel::Type::Boolean.new.cast(new_attributes[:other])
    else
      other_nationalities_hash.values.compact.any?
    end
  end

  def other_is_selected?
    ActiveModel::Type::Boolean.new.cast(new_attributes[:other])
  end

  def nationalities_cannot_be_empty
    if nationality_ids.empty?
      errors.add(:nationality_names, :empty_nationalities)
    end

    if other_is_selected? && new_attributes[:other_nationality1].blank?
      errors.add(:other_nationality1, :blank)
    end
  end

  def reset_blank_nationalities
    return if params[NATIONALITY_FIELD_MAPPINGS.keys.first].nil?

    raw_values = params.slice(*NATIONALITY_FIELD_MAPPINGS.keys).transform_keys { |key| NATIONALITY_FIELD_MAPPINGS[key.to_sym] }.select { |_key, value| value.blank? }

    params.merge!(raw_values)
  end

  def raw_values_nationalities_array
    [other_nationality1_raw, other_nationality2_raw, other_nationality3_raw]
  end

  def check_raw_values
    # check the freetext responses of the user, and if
    # they are valid responses, we use them by populating new attributes.
    # This was to fix a bug where valid responses were not being used
    # as they were not selected from the dropdown list

    raw_values_nationalities_array.each_with_index do |raw_value, index|
      next unless find_nationality(raw_value)

      public_send("other_nationality#{index + 1}=", raw_value)
      new_attributes[:"other_nationality#{index + 1}"] = raw_value
      nationality_ids[index] = find_nationality(raw_value).id
    end
  end

  def find_nationality(raw_value)
    Nationality.find_by(name: raw_value&.downcase)
  end
end
