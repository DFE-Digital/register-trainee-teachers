# frozen_string_literal: true

module Trainees
  module Confirmation
    module Record
      class View < GovukComponent::Base
        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
          @not_provided_copy = I18n.t("components.confirmation.not_provided")
        end

        def type_of_record
          if trainee.record_type.present?
            trainee.record_type.humanize
          else
            @not_provided_copy
          end
        end

        def trainee_id
          trainee.trainee_id.presence || @not_provided_copy
        end
      end
    end
  end
end
