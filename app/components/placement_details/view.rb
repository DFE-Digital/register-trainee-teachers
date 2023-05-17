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

    def urns
      @urns ||=
        trainee
          .placements
          &.map { |placement| placement["school_urn"] }
    end

    def placement_records
      return [] if urns.blank?

      # According to the data we have so far, there is only one placement record per hesa student that has a magic URN
      return [t("components.placement_detail.magic_urn.#{urns.first}")] if Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS.include?(urns.first)

      School.where(urn: urns).in_order_of(:urn, urns)
    end

    def school_details_for(school)
      "URN #{school.urn}, #{school.town}, #{school.postcode}"
    end

    def placement_rows
      placement_records.each_with_index.map do |placement_record, index|
        # This means the placement record is not an actual school and we are dealing with a magic urn
        if placement_record.is_a?(String)
          {
            field_label: t("components.placement_detail.placement_#{index + 1}"),
            field_value: tag.p(
              placement_record,
              class: "govuk-body",
            ),
          }
        else
          {
            field_label: t("components.placement_detail.placement_#{index + 1}"),
            field_value: tag.p(
              placement_record.name,
              class: "govuk-body",
            ) + tag.div(school_details_for(placement_record), class: "govuk-hint"),
          }
        end
      end
    end
  end
end
