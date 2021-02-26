# frozen_string_literal: true

module Trainees
  module Confirmation
    module ProgrammeDetails
      class View < GovukComponent::Base
        include SummaryHelper

        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def summary_title
          I18n.t("components.programme_detail.title")
        end

        def subject
          return @not_provided_copy if trainee.subject.blank?

          trainee.subject
        end

        def age_range
          return @not_provided_copy if trainee.age_range.blank?

          trainee.age_range
        end

        def programme_type
          return @not_provided_copy if trainee.training_route.blank?

          trainee.training_route.humanize
        end

        def programme_start_date
          return @not_provided_copy if trainee.programme_start_date.blank?

          date_for_summary_view(trainee.programme_start_date)
        end

        def programme_end_date
          return @not_provided_copy if trainee.programme_end_date.blank?

          date_for_summary_view(trainee.programme_end_date)
        end
      end
    end
  end
end
