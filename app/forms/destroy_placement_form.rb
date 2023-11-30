# frozen_string_literal: true

class DestroyPlacementForm
  attr_accessor :trainee, :placement, :slug

  def initialize(placements_form:, placement:, slug:)
    @placements_form = placements_form
    @trainee = placements_form.trainee
    @placement = placement
    @slug = slug
  end

  def self.find_from_param(placements_form:, slug:)
    placement = placements_form.trainee.placements.find_by(slug:)
    new(placements_form:, placement:, slug:)
  end

  def destroy_or_stash!
    if placement.blank?
      @placements_form.delete_placement_on_store(slug)
    elsif trainee.draft?
      @placements_form.destroy!(placement.slug)
    else
      @placements_form.mark_for_destruction!(slug)
    end
  end
end
