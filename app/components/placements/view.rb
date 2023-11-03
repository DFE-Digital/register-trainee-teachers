# frozen_string_literal: true

module Placements
  class View < GovukComponent::Base
    include SummaryHelper

    attr_accessor :data_model, :editable, :has_errors

    def initialize(data_model:, has_errors: false, editable: false)
      @data_model = data_model
      @editable = editable
      @has_errors = has_errors
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def render_inset?
      placement_records.size < 2
    end

    def placement_summaries
      placement_records.each_with_index.map do |placement_record, index|
        placement = placement_record.is_a?(Placement) ? placement_record : placement_record.placement
        {
          trainee: trainee,
          title: t("components.placements.placement_#{index + 1}"),
          rows: [{
            field_label: "School or setting",
            field_value: placement_details_for(placement),
            action_url: "#",
          }],
          editable: true,
          has_errors: has_errors,
        }
      end
    end

  private

    def placement_records
      @placement_records ||= data_model.placements
    end

    def placement_details_for(placement_record)
      main_tag = tag.p(
        placement_record.name,
        class: "govuk-body",
      )

      address = placement_record.full_address

      address ? main_tag + tag.div(address, class: "govuk-hint") : main_tag
    end
  end
end
