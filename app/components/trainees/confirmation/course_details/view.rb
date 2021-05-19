# frozen_string_literal: true

module Trainees
  module Confirmation
    module CourseDetails
      class View < GovukComponent::Base
        include SummaryHelper
        include CourseDetailsHelper

        attr_accessor :data_model

        def initialize(data_model:)
          @data_model = data_model
          @not_provided_copy = t("components.confirmation.not_provided")
        end

        def trainee
          data_model.is_a?(Trainee) ? data_model : data_model.trainee
        end

        def summary_title
          t("components.course_detail.title")
        end

        def course_details
          return t("components.course_detail.details_not_on_publish") if data_model.course_code.blank?

          "#{course.name} (#{course.code})"
        end

        def course
          @course ||= Course.find_by(code: data_model.course_code)
        end

        def subject
          return @not_provided_copy if data_model.subject.blank?

          subjects_for_summary_view(data_model.subject, data_model.subject_two, data_model.subject_three)
        end

        def course_age_range
          return @not_provided_copy if data_model.course_age_range.blank?

          age_range_for_summary_view(data_model.course_age_range)
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
