# frozen_string_literal: true

class PlacementForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[school_id name urn postcode].freeze

  def initialize(trainee:)
    @trainee = trainee
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Placement")
  end

  def fields; end

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

  def save!
    # TODO: Implement persistence logic
    false
  end
end
