# frozen_string_literal: true

module Api
  module HesaMapper
    module Attributes
      InvalidValue = Struct.new(:original_value) do
        delegate :to_s, to: :original_value
      end
    end
  end
end
