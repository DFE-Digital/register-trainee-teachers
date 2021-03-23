# frozen_string_literal: true

module Trainees
  module Confirmation
    module CourseDetails
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
          I18n.t("components.course_detail.title")
        end

        def subject
          return @not_provided_copy if data_model.subject.blank?

          data_model.subject
        end

        def age_range
          return @not_provided_copy if data_model.age_range.blank?

          data_model.age_range
        end

        def course_type
          return @not_provided_copy if trainee.training_route.blank?

          t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
        end

        def course_start_date
          return @not_provided_copy if data_model.course_start_date.blank?

          date_for_summary_view(data_model.course_start_date)
        end

        def course_end_date
          return @not_provided_copy if data_model.course_end_date.blank?

          date_for_summary_view(data_model.course_end_date)
        end
      end
    end
  end
end
