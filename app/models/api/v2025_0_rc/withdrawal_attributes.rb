# frozen_string_literal: true

module Api
  module V20250Rc
    class WithdrawalAttributes < Api::V01::WithdrawalAttributes
      include Api::ErrorAttributeAdapter

      attribute :record_source, default: -> { Trainee::API_SOURCE }
    end
  end
end
