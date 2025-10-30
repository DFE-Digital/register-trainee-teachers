# frozen_string_literal: true

class PersonalDetailsForm < TraineeForm
  include DatesHelper

  FIELDS = %i[
    first_names
    middle_names
    last_name
    sex
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

  before_validation :set_nationalities_from_raw_values

  validates :first_names, presence: true, length: { maximum: 60 }
  validates :last_name, presence: true, length: { maximum: 60 }
  validates :middle_names, length: { maximum: 60 }, allow_nil: true
  validates :date_of_birth, presence: true
  validate :date_of_birth_valid
  validates :sex, presence: true, inclusion: { in: Trainee.sexes.keys + Trainee.sexes.values }
  validates :other_nationality1,
            :other_nationality2,
            :other_nationality3,
            autocomplete: true,
            allow_nil: true,
            if: :other_is_selected?
  validate :nationalities_cannot_be_empty, unless: -> { trainee.hesa_record? }

  def date_of_birth
    date_hash = { year:, month:, day: }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
  end

  def save!
    if valid?
      update_trainee_attributes
      Trainees::Update.call(trainee:)
      clear_stash
    else
      false
    end
  end

  def nationality_names
    @nationality_names ||= nationality_ids.map { |id| Nationality.find(id).name.titleize_with_hyphens }
  end

  def nationality_ids
    @nationality_ids ||=
      begin
        nationality_params = new_attributes.merge(blank_nationalities_params)

        if nationality_params[:nationality_names].blank?
          trainee.nationality_ids
        else
          nationalities = nationality_params[:nationality_names]

          if other_is_selected?
            nationalities += [
              nationality_params[:other_nationality1],
              nationality_params[:other_nationality2],
              nationality_params[:other_nationality3],
            ]
          end

          nationalities.compact_blank
            .map { |name| Nationality.find_by_name(name.downcase)&.id }.uniq.compact
        end
      end
  end

private

  def new_attributes
    @_new_attributes ||= super
  end

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
          date_of_birth:, nationality_ids:,
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
    @other_nationalities_hash ||=
      begin
        # Re-hydrate the 'Other nationality' fields from the trainee model.
        nationality1, nationality2, nationality3 = trainee.nationalities.where.not(name: %w[british irish]).pluck(:name).map(&:titleize_with_hyphens)

        {
          other_nationality1: nationality1,
          other_nationality2: nationality2,
          other_nationality3: nationality3,
        }
      end
  end

  def date_of_birth_valid
    if !date_of_birth.is_a?(Date)
      errors.add(:date_of_birth, :invalid)
    elsif date_of_birth > Time.zone.today
      errors.add(:date_of_birth, :future)
    elsif date_of_birth.year.digits.length != 4
      errors.add(:date_of_birth, :invalid_year)
    elsif date_of_birth > 16.years.ago
      errors.add(:date_of_birth, :under16)
    elsif date_of_birth < 100.years.ago
      errors.add(:date_of_birth, :past)
    end
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

  def blank_nationalities_params
    return {} if params[NATIONALITY_FIELD_MAPPINGS.keys.first].nil?

    if other_is_selected?
      params.slice(*NATIONALITY_FIELD_MAPPINGS.keys).transform_keys { |key| NATIONALITY_FIELD_MAPPINGS[key.to_sym] }.select { |_key, value| value.blank? }
    else
      {
        other_nationality1: "",
        other_nationality2: "",
        other_nationality3: "",
        other_nationality1_raw: "",
        other_nationality2_raw: "",
        other_nationality3_raw: "",
      }
    end
  end

  def raw_values_nationalities_array
    [other_nationality1_raw, other_nationality2_raw, other_nationality3_raw]
  end

  def set_nationalities_from_raw_values
    return unless other_is_selected?

    # check the freetext responses of the user, and if
    # they are valid responses, we use them by populating new attributes.
    # This was to fix a bug where valid responses were not being used
    # as they were not selected from the dropdown list

    raw_values_nationalities_array.each_with_index do |raw_value, index|
      found_nationality = find_nationality(raw_value)
      next unless found_nationality

      titleized_name = found_nationality.name.titleize_with_hyphens
      public_send("other_nationality#{index + 1}=", titleized_name)
      new_attributes[:"other_nationality#{index + 1}"] = titleized_name
      new_attributes[:"other_nationality#{index + 1}_raw"] = titleized_name
      public_send("other_nationality#{index + 1}_raw=", titleized_name)

      nationality_ids << found_nationality.id if nationality_ids.exclude?(found_nationality.id)
    end
  end

  def find_nationality(raw_value)
    Nationality.find_by(name: raw_value&.downcase)
  end
end
