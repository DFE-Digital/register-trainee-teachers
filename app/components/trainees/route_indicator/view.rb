# frozen_string_literal: true

module Trainees
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
          "Trainee enrolled on #{course_with_code}, #{training_route}"
        else
          "Trainee on the #{training_route_link} route".html_safe
        end
      end

      def course_with_code
        "#{trainee.subject} #{course_code}".strip
      end

      def course_code
        return unless course&.code

        "(#{course.code})"
      end

      def course
        @course ||= trainee.provider.courses.find_by(name: trainee.subject)
      end

      def training_route
        t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}")
      end

      def training_route_link
        govuk_link_to training_route.downcase, edit_trainee_training_route_path(trainee)
      end
    end
  end
end
