# frozen_string_literal: true

class PlacementForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[slug school_search school_id name urn postcode].freeze
  URN_REGEX = /^[0-9]{6}$/

  attr_accessor(*FIELDS, :placements_form, :placement, :trainee, :destroy)

  validate :school_valid, on: %i[create update]
  validate :school_or_search_valid
  validates :name, presence: true, if: -> { school_id.blank? && school_search.blank? }
  validate :urn_valid
  validate :postcode_valid

  delegate :persisted?, :school, to: :placement

  alias_method :to_param, :slug
  alias_method :destroy?, :destroy

  def initialize(placements_form:, placement:, destroy: false)
    @placements_form = placements_form
    @trainee = placements_form.trainee
    @placement = placement
    @destroy = destroy
    self.attributes = placement.attributes.symbolize_keys.slice(*FIELDS)
    self.school_search = placement.school_search
  end

  # This method is called by PlacementsController#edit to populate the school
  # search field with the name of the currently selected school. It shouldn't
  # be called elsewhere as the presence of the `school_search` field triggers
  # the non-JS flow in other actions (e.g. `create` and `update`).
  def initialise_school_search_for_edit
    self.school_search ||= @placement&.school&.name
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Placement")
  end

  def fields
    placement.attributes.symbolize_keys.slice(*FIELDS).merge(attributes)
  end

  def update_placement(attrs)
    rely_on_school_name = attrs[:school_id].blank? || (attrs[:school_id] == school_id.to_s && attrs[:name].present?)

    reset_hash = (rely_on_school_name ? [:school_id] : %i[name urn postcode]).index_with { nil }

    update_attributes = attrs.slice(:school_id, :name, :urn, :postcode).merge(reset_hash)

    assign_attributes(update_attributes)
  end

  def attributes
    FIELDS.index_with do |f|
      public_send(f)
    end
  end

  def attributes=(attrs)
    attrs.slice(*FIELDS).each do |k, v|
      public_send(:"#{k}=", v)
    end
  end

  def school_name
    school&.name
  end

  def title
    I18n.t(
      "components.placement_detail.placement_#{placement_number}",
      default: I18n.t("components.placement_detail.title"),
    )
  end

  def save_or_stash
    if trainee.draft?
      save!
    else
      stash
    end
  end

  def stash
    return false unless valid?

    placements_form.stash_placement_on_store(slug, fields)
    true
  end

  def save!
    return false unless valid?

    if persisted?
      if destroy?
        destroy_placement
      else
        placement.update(attributes)
      end
    elsif placements_form.placements.any? { |form| form.placement.slug == placement.slug }
      placement.update(attributes)
    else
      create_placement unless destroy?
    end

    placements_form.delete_placement_on_store(slug)
    true
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

  def school_valid
    if school_id.blank? && [name, urn, postcode].all?(&:blank?)
      errors.add(:school_id, :blank)
    end
  end

  def school_or_search_valid
    if school_id.blank? && school_search.blank? && (name.blank? && urn.blank? && postcode.blank?)
      errors.add(:school, :blank)
    end
  end

  def open_details?
    %i[name urn].intersect?(errors.attribute_names)
  end

  def urn_valid
    if urn.present? && !urn.match?(URN_REGEX)
      errors.add(:urn, :invalid_format)
    end
  end

  def postcode_valid
    if postcode.present? && !UKPostcode.parse(postcode).valid?
      errors.add(:postcode, I18n.t("activemodel.errors.validators.postcode.invalid"))
    end
  end

private

  def existing_urns
    trainee.placements.filter_map do |placement|
      next if placement.slug == slug

      placement.school&.urn || placement.urn
    end
  end

  def placement_number
    (placements_form.placements.index { |form| form.placement.slug == placement.slug } || placements_form.placements.count) + 1
  end

  def create_placement
    if school_id.present? && (school = School.find_by(id: school_id)).present?
      create_placement_for(school:)
    else
      create_placement_for(placement_details)
    end
  end

  def destroy_placement
    placement.destroy!
  end

  def create_placement_for(attrs)
    trainee.placements.create!(attrs)
  end

  def placement_details
    {
      name:,
      urn:,
      postcode:,
    }
  end
end
