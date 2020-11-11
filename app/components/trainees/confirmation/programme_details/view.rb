module Trainees
  module Confirmation
    module ProgrammeDetails
      class View < GovukComponent::Base
        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
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

          trainee.programme_start_date.strftime("%-d %B %Y")
        end
      end
    end
  end
end
