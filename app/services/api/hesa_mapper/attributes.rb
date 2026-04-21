# frozen_string_literal: true

module Api
  module HesaMapper
    module Attributes
      # source_attribute tracks which input field (e.g. :training_partner_urn)
      # produced the invalid value, so validation errors reference the right field.
      InvalidValue = Struct.new(:original_value, :source_attribute) do
        delegate :to_s, to: :original_value
      end
    end
  end
end
