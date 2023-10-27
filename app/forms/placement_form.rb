# frozen_string_literal: true

class PlacementForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[slug school_id name urn postcode].freeze
  attr_accessor(*FIELDS)

  validates :school_id, presence: true, unless: -> { name.present? }
  validates :name, presence: true, unless: -> { school_id.present? }
  validates :urn, presence: true, unless: -> { school_id.present? }

  delegate :persisted?, to: :degree

  alias_method :to_param, :slug

  def initialize(placements_form:, placement:)
    @placements_form = placements_form
    @trainee = @placements_form.trainee
    @placement = placement
    self.attributes = placement.attributes.symbolize_keys.slice(*FIELDS)
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Placement")
  end

  def fields
    placement.attributes.symbolize_keys.slice(*FIELDS).merge(attributes)
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

  def title
    new_placement_number = @trainee.placements.count + 1
    I18n.t(
      "components.placement_detail.placement_#{new_placement_number}",
      default: I18n.t("components.placement_detail.title"),
    )
  end

  def save_or_stash
    if placements_form.trainee.draft?
      if save!
        true
      end
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

    if school_id.present? && (school = School.find_by(id: school_id)).present?
      create_placement_for(school:)
    else
      create_placement_for(placement_details)
    end
    placements_form.delete_placement_on_store(slug)
    true
  end

  def destroy!
    placements_form.delete_placement_on_store(slug)
    placement.destroy! unless placement_record?
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

  def create_placement_for(attrs)
    @trainee.placements.create!(attrs)
  end

  def placement_details
    {
      name:,
      urn:,
      postcode:,
    }
  end
end
