module Trainees
  module Diversity
    class ConfirmDetailsController < Trainees::ConfirmDetailsController
    private

      def component_klass(_key)
        "Trainees::Confirmation::Diversity::View".constantize
      end
    end
  end
end
