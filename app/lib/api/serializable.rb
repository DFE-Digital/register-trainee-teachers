# frozen_string_literal: true

module Api
  module Serializable
  private

    def serializer_klass
      @serializer_klass ||= Api::GetVersionedItem.for_serializer(model:, version:)
    end
  end
end
