# frozen_string_literal: true

class DegreeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    slug
    locale_code
    uk_degree
    non_uk_degree
    subject
    institution
    graduation_year
    grade
    other_grade
    country
  ].freeze

  AUTOCOMPLETE_FIELDS = %i[
    uk_degree_raw
    subject_raw
    institution_raw
  ].freeze

  attr_accessor(*FIELDS, *AUTOCOMPLETE_FIELDS, :degrees_form, :degree)

  validates :subject, :institution, autocomplete: true, allow_nil: true
  validate :validate_with_degree_model

  validates :institution, inclusion: { in: Degree::INSTITUTIONS }, allow_nil: true
  validates :subject, inclusion: { in: Degree::SUBJECTS }, allow_nil: true

  delegate :uk?, :non_uk?, :non_uk_degree_non_enic?, :persisted?, to: :degree

  alias_method :to_param, :slug

  def initialize(degrees_form:, degree:, autocomplete_params: {})
    @degrees_form = degrees_form
    @degree = degree
    self.attributes = degree.attributes.symbolize_keys.slice(*FIELDS)
    assign_attributes(autocomplete_params)
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Degree")
  end

  def fields
    degree.attributes.symbolize_keys.slice(*FIELDS).merge(attributes)
  end

  def attributes
    FIELDS.index_with do |f|
      public_send(f)
    end
  end

  def attributes=(attrs)
    attrs.each do |k, v|
      public_send(:"#{k}=", v)
    end
  end

  def save_or_stash
    if degrees_form.trainee.draft?
      if save!
        clear_relevant_invalid_apply_data if apply_invalid_data_includes_slug? && errors.empty?
        true
      end
    else
      stash
    end
  end

  def stash
    return false unless valid?

    degrees_form.stash_degree_on_store(slug, fields)
    true
  end

  def save!
    return false unless valid?

    degree.attributes = fields
    degree.save!(context: locale_code.to_sym)
    degrees_form.delete_degree_on_store(slug)
    true
  end

  def destroy!
    degrees_form.delete_degree_on_store(slug)
    degree.destroy! unless degree.new_record?
  end

  def save_and_return_invalid_data!
    invalid_data = {}

    valid?

    errors.each do |error|
      invalid_data[error.attribute.to_sym] = send(error.attribute)
      send("#{error.attribute}=", nil)
    end

    save_or_stash && invalid_data
  end

private

  def validate_with_degree_model
    degree.attributes = fields
    unless degree.valid?(locale_code.to_sym)
      degree.errors.each do |e|
        errors.add(e.attribute, e.message)
      end
    end
  end

  def apply_invalid_data_includes_slug?
    return unless degrees_form.trainee.invalid_apply_data?

    degrees_form.trainee.apply_application.invalid_data["degrees"].keys.include? slug
  end

  def clear_relevant_invalid_apply_data
    degrees_form.trainee.apply_application.invalid_data.tap { |invalid_data| invalid_data["degrees"].delete(slug) }
    degrees_form.trainee.apply_application.save!
  end
end
