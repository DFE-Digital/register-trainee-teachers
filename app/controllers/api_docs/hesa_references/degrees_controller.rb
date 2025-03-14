# frozen_string_literal: true

module ApiDocs
  class HesaReferences::DegreesController < HesaReferenceController
    def show
      @attribute = params[:attribute]
      @mapper    = degree_hesa_mapper_class::HESA_MAPPING[@attribute.to_sym]
    end
  end
end
