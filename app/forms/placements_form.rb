# frozen_string_literal: true

class PlacementsForm
  include ActiveModel::Model

  attr_accessor :trainee, :placement_ids

  # validate :placement_ids, length: { mininum: 2 }
  validate :placements_must_be_valid

  MINIMUM_PLACEMENTS = 2

  def initialize(trainee, store = FormStore)
    @trainee = trainee
    @store = store
    super(fields)
  end

  def fields
    { placement_ids: trainee.placement_ids }
  end

  def build_placement_form(placement_params)
    PlacementForm.new(
      placements_form: self,
      placement: trainee.placements.new(placement_params),
    )
  end

  def find_placement_from_param(slug)
    if (placement = trainee.placements.find_by(slug:))
      form = PlacementForm.new(placements_form: self, placement: placement)
      # Load stored attributes
      form.attributes = fetch_store[placement.slug] || {}
    elsif (attrs = fetch_store[slug]).present?
      # Unsaved stored placement
      form = build_placement_form(attrs)
    else
      raise(ActiveRecord::RecordNotFound, "Couldn't find Placement")
    end

    form
  end

  def placements
    slug_placements_forms_map = {}

    trainee.placements.includes([:school]).order(created_at: :asc).each do |placement|
      slug_placements_forms_map[placement.slug] = PlacementForm.new(placements_form: self, placement: placement)
    end

    fetch_store.each do |slug, attrs|
      # Initialize stored unsaved placement
      slug_placements_forms_map[slug] ||= build_placement_form(attrs)
      # Load any stored attributes
      slug_placements_forms_map[slug].attributes = attrs
    end

    slug_placements_forms_map.values
  end

  def stash_placement_on_store(slug, fields)
    placements = fetch_store
    placements[slug] = fields
    save_store(placements)
  end

  def delete_placement_on_store(slug)
    placements = fetch_store
    placements.delete(slug)
    save_store(placements)
  end

  def save!
    placements.each(&:save!)
  end

  def missing_fields(include_placement_id: false)
    return [] if valid?

    placements.map do |placement_form|
      placement_form.valid?
      if include_placement_id
        { placement_form.slug => placement_form.errors.attribute_names }
      else
        placement_form.errors.attribute_names
      end
    end
  end

  def trainee_reset_placements?
    !trainee.draft? && trainee.placements.empty? && !placements.all?(&:persisted?)
  end

private

  attr_reader :store

  def fetch_store
    store.get(trainee.id, :placements) || {}
  end

  def save_store(placements)
    store.set(trainee.id, :placements, placements)
  end

  def placements_must_be_valid
    errors.add(:placement_ids, :invalid) if any_placements_are_invalid?
  end

  def any_placements_are_invalid?
    placements.any?(&:invalid?)
  end
end
