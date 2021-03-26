# frozen_string_literal: true

class DegreesForm
  include ActiveModel::Model

  attr_accessor :trainee, :degree_ids

  validate :degrees_cannot_be_empty

  def initialize(trainee, store = FormStore)
    @trainee = trainee
    @store = store
    super(fields)
  end

  def fields
    { degree_ids: trainee.degree_ids }
  end

  def build_degree(params)
    DegreeForm.new(degrees_form: self, degree: trainee.degrees.new(params))
  end

  def find_degree_from_param(slug)
    if (degree = trainee.degrees.find_by(slug: slug))
      form = DegreeForm.new(degrees_form: self, degree: degree)
      # Load stored attributes
      form.attributes = get_store[degree.slug] || {}
    elsif (attrs = get_store[slug]).present?
      # Unsaved stored degree
      form = build_degree(attrs)
    else
      raise ActiveRecord::RecordNotFound, "Couldn't find Degree"
    end

    form
  end

  def degrees
    @degrees = {}

    trainee.degrees.order(created_at: :asc).each do |degree|
      @degrees[degree.slug] = DegreeForm.new(degrees_form: self, degree: degree)
    end

    get_store.each do |slug, attrs|
      # Initialize stored unsaved degree
      @degrees[slug] ||= build_degree(attrs)
      # Load any stored attributes
      @degrees[slug].attributes = attrs
    end

    @degrees.values
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
end
