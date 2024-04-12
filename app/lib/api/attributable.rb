# frozen_string_literal: true

module Api
  module Attributable
  private

    def attributes_klass
      @attributes_klass ||= Api::Attributes.for(model:, version:)
    end
  end
end
