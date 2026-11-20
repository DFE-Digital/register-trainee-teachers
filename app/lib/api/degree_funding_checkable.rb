# frozen_string_literal: true

module Api
  module DegreeFundingCheckable
  private

    def funding_check_klass
      @funding_check_klass ||= Api::GetVersionedItem.for_service(model: :degree_funding_check, version: version)
    end
  end
end
