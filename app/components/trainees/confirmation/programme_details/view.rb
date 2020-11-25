# frozen_string_literal: true

module Trainees
  module Confirmation
    module ProgrammeDetails
      class View < GovukComponent::Base
        include SummariesHelper

        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def summary_title
          I18n.t("components.programme_detail.title", record_type: format_record_type)
        end

        def subject
          return @not_provided_copy if trainee.subject.blank?

          trainee.subject
        end

        def age_range
          return @not_provided_copy if trainee.age_range.blank?

          trainee.age_range
        end

        def programme_start_date
          return @not_provided_copy if trainee.programme_start_date.blank?

          date_for_summary_view(trainee.programme_start_date)
        end

      private

        def format_record_type
          trainee.record_type.humanize
        end
      end
    end
  end
end
