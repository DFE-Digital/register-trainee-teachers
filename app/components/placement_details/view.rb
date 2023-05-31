# frozen_string_literal: true

module PlacementDetails
  class View < GovukComponent::Base
    include SummaryHelper

    attr_accessor :trainee, :editable, :has_errors, :show_link

    def initialize(trainee:, link: true, has_errors: false, editable: false)
      @trainee = trainee
      @editable = editable
      @has_errors = has_errors
      @show_link = show_link?(link)
    end

    def summary_title
      t("components.placement_detail.title")
    end

    def rows
      placement_rows
    end

  private

    def show_link?(link)
      return false if !editable

      link
    end

    def placement_records
      trainee.placements.reverse
    end

    def placement_rows
      placement_records.each_with_index.map do |placement_record, index|
        {
          field_label: t("components.placement_detail.placement_#{index + 1}"),
          field_value: placement_details_for(placement_record),
        }
      end
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
