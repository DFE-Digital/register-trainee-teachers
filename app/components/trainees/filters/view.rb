# frozen_string_literal: true

module Trainees
  module Filters
    class View < GovukComponent::Base
      include ProgrammeDetailsHelper
      attr_accessor :filters

      with_content_areas :filter_actions

      def initialize(filters)
        @filters = filters
      end

    private

      def label_for(attribute, value)
        I18n.t("activerecord.attributes.trainee.#{attribute.pluralize}.#{value}")
      end

      def title_html(filter, value)
        tag.span("Remove ", class: "govuk-visually-hidden") + value + tag.span(" #{filter.humanize.downcase} filter", class: "govuk-visually-hidden")
      end

      def checked?(filter, value)
        filters && filters[filter]&.include?(value)
      end

      def tags_for_filter(filter, value)
        case value
        when String
          [{ title: title_html(filter, value), remove_link: remove_select_tag_link(filter) }]
        else
          value.each_with_object([]) do |v, arr|
            arr << {
              title: title_html(filter, label_for(filter, v)),
              remove_link: remove_checkbox_tag_link(filter, v),
            }
          end
        end
      end

      def remove_checkbox_tag_link(filter, value)
        new_filters = filters.deep_dup
        new_filters[filter].reject! { |v| v == value }
        "?" + new_filters.to_query
      end

      def remove_select_tag_link(filter)
        new_filters = filters.reject { |f| f == filter }
        "?" + new_filters.to_query
      end

      def filter_label_for(filter)
        I18n.t("components.filter.#{filter}")
      end
    end
  end
end
