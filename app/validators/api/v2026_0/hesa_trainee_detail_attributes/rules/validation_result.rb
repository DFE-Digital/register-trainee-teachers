# frozen_string_literal: true

module Api
  module V20260
    class HesaTraineeDetailAttributes
      module Rules
        ValidationResult = Struct.new(:valid?, :error_type, :error_details)
      end
    end
  end
end
