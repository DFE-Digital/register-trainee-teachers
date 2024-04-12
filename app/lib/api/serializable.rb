# frozen_string_literal: true

module Api
  module Serializable
  private

    def serializer_klass
      @serializer_klass ||= Serializer.for(model:, version:)
    end
  end
end
