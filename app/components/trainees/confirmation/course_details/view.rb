# frozen_string_literal: true

module Trainees
  module Confirmation
    module CourseDetails
      class View < GovukComponent::Base
        include SummaryHelper

        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def summary_title
          I18n.t("components.course_detail.title")
        end

        def subject
          return @not_provided_copy if trainee.subject.blank?

          trainee.subject
        end

        def age_range
          return @not_provided_copy if trainee.age_range.blank?

          trainee.age_range
        end

        def course_type
          return @not_provided_copy if trainee.training_route.blank?

          t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
        end

        def course_start_date
          return @not_provided_copy if trainee.course_start_date.blank?

          date_for_summary_view(trainee.course_start_date)
        end

        def course_end_date
          return @not_provided_copy if trainee.course_end_date.blank?

          date_for_summary_view(trainee.course_end_date)
        end
      end
    end
  end
end
