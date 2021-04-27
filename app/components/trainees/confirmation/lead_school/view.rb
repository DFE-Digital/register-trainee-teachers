# frozen_string_literal: true

module Trainees
  module Confirmation
    module LeadSchool
      class View < GovukComponent::Base
        include SummaryHelper

        attr_accessor :data_model

        def initialize(data_model:)
          @data_model = data_model
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def trainee
          data_model.is_a?(Trainee) ? data_model : data_model.trainee
        end

        def summary_title
          t(".summary_title")
        end

        def lead_school_name
          return @not_provided_copy if lead_school&.name.blank?

          lead_school.name
        end

        def lead_school_location
          return @not_provided_copy if lead_school&.urn.blank?

          ["URN #{lead_school.urn}", lead_school.town, lead_school.postcode].select(&:present?).join(", ")
        end

        def lead_school_partial
          tag.p(lead_school_name, class: "govuk-body") +
            tag.span(lead_school_location, class: "govuk-hint")
        end

        def lead_school
          @lead_school ||= School.where(id: data_model.lead_school_id).first
        end

        def edit_path
          trainee_lead_schools_path(trainee)
        end
      end
    end
  end
end
