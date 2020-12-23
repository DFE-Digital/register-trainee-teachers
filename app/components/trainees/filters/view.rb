# frozen_string_literal: true

module Trainees
  module Filters
    class View < GovukComponent::Base
      include ProgrammeDetailsHelper
      attr_accessor :filters

      def initialize(filters)
        @filters = filters
      end

    private

      def label_for(attribute, value)
        I18n.t("activerecord.attributes.trainee.#{attribute.pluralize}.#{value}")
      end

      def checked?(filter, value)
        filters[filter]&.include?(value)
      end

      def active_filters
        filters.deep_dup.reject! do |filter, value|
          value.empty? || (filter == "subject" && value == "All subjects")
        end
      end

      def tags_for_active_filter(filter, value)
        case value
        when String
          [{ title: value, remove_link: remove_select_tag_link(filter) }]
        else
          value.each_with_object([]) do |v, arr|
            arr << {
              title: label_for(filter, v),
              remove_link: remove_checkbox_tag_link(filter, v),
            }
          end
        end
      end

      def remove_checkbox_tag_link(filter, value)
        new_filters = active_filters
        new_filters[filter].reject! { |v| v == value }
        "?" + new_filters.to_query
      end

      def remove_select_tag_link(filter)
        new_filters = active_filters.reject { |f| f == filter }
        "?" + new_filters.to_query
      end
    end
  end
end
