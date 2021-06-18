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
        t(".apply_display_text", course_with_code: course_with_code, training_route: training_route)
      else
        t(".display_text", training_route_link: training_route_link).html_safe
      end
    end

    def course_with_code
      "#{trainee.course_subject_one} #{course_code}".strip
    end

    def course_code
      return if trainee.course_code.blank?

      "(#{trainee.course_code})"
    end

    def training_route
      t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
    end

    def training_route_link
      govuk_link_to training_route.downcase, edit_trainee_training_route_path(trainee)
    end
  end
end
