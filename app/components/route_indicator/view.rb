# frozen_string_literal: true

module RouteIndicator
  class View < GovukComponent::Base
    include TraineeHelper

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def render?
      trainee.training_route.present? && trainee.draft?
    end

    def display_text
      if trainee.apply_application?
        t(".apply_display_text", course_with_code: course_with_code.upcase_first, training_route: training_route.downcase)
      else
        t(".display_text", training_route_link: training_route_link).html_safe
      end
    end

    def course_with_code
      "#{trainee.course_subject_one || course_name} #{course_code}".strip
    end

    def course_code
      if trainee.apply_application?
        apply_course_code
      else
        manual_course_code
      end
    end

    def manual_course_code
      return if trainee.published_course.blank?

      "(#{trainee.published_course.code})"
    end

    def apply_course_code
      return if trainee.apply_application.course.blank?

      "(#{trainee.published_course&.code || trainee.apply_application.course.code})"
    end

    def training_route
      t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
    end

    def training_route_link
      govuk_link_to(training_route.downcase, edit_trainee_training_route_path(trainee))
    end

    def course_name
      trainee.published_course&.name || trainee.apply_application.course&.name
    end
  end
end
