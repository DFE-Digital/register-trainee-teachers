# frozen_string_literal: true

module Trainees
  module SchoolDetails
    class View < GovukComponent::Base
      attr_reader :trainee, :lead_school, :employing_school

      TYPES = {
        lead: "lead",
        employing: "employing",
      }.freeze

      def initialize(trainee)
        @trainee = trainee
        @lead_school = trainee.lead_school
        @employing_school = trainee.employing_school
      end

      def school_rows
        [lead_school_row, employing_school_row].compact
      end

      def lead_school_row
        return if lead_school.blank?

        {
          key: t("components.school_details.lead_school_key"),
          value: school_detail(lead_school),
          action: change_link(TYPES[:lead]),

        }
      end

      def employing_school_row
        return if employing_school.blank?

        {
          key: t("components.school_details.employing_school_key"),
          value: school_detail(employing_school),
          action: change_link(TYPES[:employing]),
        }
      end

    private

      def school_detail(school)
        tag.p(school.name, class: "govuk-body") + tag.span(location(school), class: "govuk-hint")
      end

      def location(school)
        ["URN #{school.urn}", school.town, school.postcode].select(&:present?).join(", ")
      end

      def change_link(school_type)
        govuk_link_to("Change<span class='govuk-visually-hidden'> #{school_type} school</span>".html_safe, change_paths(school_type))
      end

      def change_paths(school_type)
        {
          lead: trainee_lead_schools_path(trainee),
          employing: trainee_employing_schools_path(trainee),
        }[school_type.to_sym]
      end
    end
  end
end
