# frozen_string_literal: true

module ApiDocs
  class HesaReferenceController < ApiDocs::BaseController
    layout "application"

    helper_method :trainee_hesa_mapper_class
    helper_method :degree_hesa_mapper_class
    helper_method :version

    def index;end

  private

    def trainee_hesa_mapper_class
      Api::GetVersionedItem.for_service(model: :map_hesa_attributes, version: version)
    end

    def degree_hesa_mapper_class
      Api::GetVersionedItem.for_service(model: :degree, version: version)
    end

    alias_method :version, :api_version
  end
end
