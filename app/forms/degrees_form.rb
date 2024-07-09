# frozen_string_literal: true

class DegreesForm
  include ActiveModel::Model

  attr_accessor :trainee, :degree_ids

  validate :degrees_cannot_be_empty
  validate :degrees_cannot_be_invalid

  def initialize(trainee, store = FormStore)
    @trainee = trainee
    @store = store
    super(fields)
  end

  def fields
    { degree_ids: trainee.degree_ids }
  end

  def build_degree(degree_params, autocomplete_params = {})
    DegreeForm.new(degrees_form: self, degree: trainee.degrees.new(degree_params), autocomplete_params: autocomplete_params)
  end

  def find_degree_from_param(slug)
    if (degree = trainee.degrees.find_by(slug:))
      form = DegreeForm.new(degrees_form: self, degree: degree)
      # Load stored attributes
      form.attributes = get_store[degree.slug] || {}
    elsif (attrs = get_store[slug]).present?
      # Unsaved stored degree
      form = build_degree(attrs)
    else
      raise(ActiveRecord::RecordNotFound, "Couldn't find Degree")
    end

    form
  end

  def degrees
    slug_degree_forms_map = {}

    trainee.degrees.order(created_at: :asc).each do |degree|
      slug_degree_forms_map[degree.slug] = DegreeForm.new(degrees_form: self, degree: degree)
    end

    get_store.each do |slug, attrs|
      # Initialize stored unsaved degree
      slug_degree_forms_map[slug] ||= build_degree(attrs)
      # Load any stored attributes
      slug_degree_forms_map[slug].attributes = attrs
    end

    slug_degree_forms_map.values
  end

  def stash_degree_on_store(slug, fields)
    degrees = get_store
    degrees[slug] = fields
    set_store(degrees)
  end

  def delete_degree_on_store(slug)
    degrees = get_store
    degrees.delete(slug)
    set_store(degrees)
  end

  def save!
    degrees.each(&:save!)
  end

  def missing_fields(include_degree_id: false)
    return [] if valid?

    degrees.map do |degree_form|
      degree_form.valid?

      if include_degree_id
        { degree_form.slug => degree_form.errors.attribute_names }
      else
        degree_form.errors.attribute_names
      end
    end
  end

  def trainee_reset_degrees?
    !trainee.draft? && trainee.degrees.empty? && !degrees.all?(&:persisted?)
  end

private

  attr_reader :store

  def get_store
    store.get(trainee.id, :degrees) || {}
  end

  def set_store(degrees)
    store.set(trainee.id, :degrees, degrees)
  end

  def degrees_cannot_be_empty
    errors.add(:degree_ids, :empty_degrees) if trainee.degrees.empty?
  end

  def degrees_cannot_be_invalid
    errors.add(:degree_ids, :invalid) unless all_degrees_are_valid?
  end

  def all_degrees_are_valid?
    degrees.all?(&:valid?)
  end
end
