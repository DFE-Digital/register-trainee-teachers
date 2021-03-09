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

      def training_route_link
        govuk_link_to t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}").downcase, edit_trainee_training_route_path(trainee)
      end
    end
  end
end
