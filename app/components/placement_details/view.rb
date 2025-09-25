# frozen_string_literal: true

module PlacementDetails
  class View < ApplicationComponent
    include SummaryHelper

    attr_accessor :data_model, :editable, :has_errors, :header_level

    def initialize(data_model:, has_errors: false, editable: false, header_level: 2)
      @data_model = data_model
      @editable = editable
      @has_errors = has_errors
      @header_level = header_level
    end

    def summary_title
      t("components.placement_detail.title")
    end

    def rows
      placement_rows + missing_placements
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

  private

    def placement_records
      trainee.placements.includes([:school])
    end

    def placement_rows
      placement_records.each_with_index.map do |placement_record, index|
        {
          field_label: t("components.placement_detail.placement_#{index + 1}", default: "#{(index + 1).ordinalize} Placement"),
          field_value: placement_details_for(placement_record),
        }
      end
    end

    def missing_placements
      [
        (missing(first_placement: true) if placement_records.size < 2),
        (missing if placement_records.empty?),
      ].compact
    end

    def missing(first_placement: false)
      placement_nominal = first_placement ? placement_records.count + 1 : 2

      field_label = t("components.placement_detail.placement_#{placement_nominal}")
      link = govuk_link_to("Enter #{field_label.downcase}", new_trainee_placement_path(trainee)) if first_placement && editable

      field_value = tag.div(
        tag.p("#{field_label} is missing", class: "app-inset-text__title") + link,
        class: "govuk-inset-text app-inset-text--narrow-border app-inset-text--important",
      )

      {
        field_label:,
        field_value:,
      }
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
