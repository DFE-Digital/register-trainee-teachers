# frozen_string_literal: true

module Api
  module V20250Rc
    class HesaTraineeDetailAttributes
      module Rules
        ValidationResult = Struct.new(:valid?, :error_details)
      end
    end
  end
end
