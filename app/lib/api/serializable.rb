# frozen_string_literal: true

module Api
  module Serializable
  private

    def serializer_klass
      @serializer_klass ||= Api::Serializer.for(model:, version:)
    end
  end
end
