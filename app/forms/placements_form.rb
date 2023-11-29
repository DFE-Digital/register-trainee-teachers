# frozen_string_literal: true

class PlacementsForm
  include ActiveModel::Model

  attr_accessor :trainee, :placement_ids

  validates :placement_ids, length: { minimum: 2 }, if: :non_draft_trainee?
  validate :placements_must_be_valid, if: :non_draft_trainee?

  MINIMUM_PLACEMENTS = 2

  def initialize(trainee, store = FormStore)
    @trainee = trainee
    @store = store
    super(fields)
  end

  def non_draft_trainee? = !trainee.draft?

  def fields
    { placement_ids: trainee.placement_ids }
  end

  def build_placement_form(placement_params)
    PlacementForm.new(
      placements_form: self,
      placement: trainee.placements.new(placement_params.slice(*PlacementForm::FIELDS)),
      destroy: placement_params[:destroy],
    )
  end

  def find_placement_from_param(slug)
    if (placement = trainee.placements.find_by(slug:))
      attrs = fetch_store[placement.slug] || {}
      form = PlacementForm.new(
        placements_form: self,
        placement: placement,
        destroy: attrs[:destroy],
      )
      # Load stored attributes
      form.attributes = attrs
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
      slug_placements_forms_map[placement.slug] = PlacementForm.new(
        placements_form: self,
        placement: placement,
      )
    end

    fetch_store.each do |slug, attrs|
      # Initialize stored unsaved placement
      slug_placements_forms_map[slug] ||= build_placement_form(attrs)
      # Load any stored attributes
      slug_placements_forms_map[slug].assign_attributes(attrs)
      slug_placements_forms_map[slug].placement.assign_attributes(attrs.except(:destroy))
    end

    slug_placements_forms_map.values
  end

  def stash_placement_on_store(slug, fields)
    stored_placements = fetch_store
    stored_placements[slug] = fields
    save_store(stored_placements)
  end

  def mark_for_destruction!(slug)
    stored_placements = fetch_store
    if stored_placements[slug]
      stored_placements[slug][:destroy] = true
    else
      stored_placements[slug] = Placement.find_by(slug:).attributes.symbolize_keys.slice(*PlacementForm::FIELDS).merge(destroy: true)
    end
    save_store(stored_placements)
  end

  def destroy!(slug)
    Placement.find_by(slug:).destroy!
    delete_placement_on_store(slug)
  end

  def delete_placement_on_store(slug)
    placements = fetch_store
    placements.delete(slug)
    save_store(placements)
  end

  def save!
    trainee.has_placement_detail! unless trainee.has_placement_detail?
    placements.each(&:save!)
  end

  def missing_fields
    []
  end

  def trainee_reset_placements?
    !trainee.draft? && trainee.placements.empty? && !placements.all?(&:persisted?)
  end

private

  attr_reader :store

  def fetch_store
    (store.get(trainee.id, :placements) || {}).with_indifferent_access
  end

  def save_store(placements)
    store.set(trainee.id, :placements, placements)
  end

  def placements_must_be_valid
    errors.add(:placement_ids, :invalid) if any_invalid_placements?
  end

  def any_invalid_placements? = placements.any?(&:invalid?)
end
