# frozen_string_literal: true

module ApiDocs
  class HesaReferences::TraineesController < HesaReferenceController
    def show
      @attribute = params[:attribute]
      @mapper    = trainee_hesa_mapper_class::HESA_MAPPING[@attribute.to_sym]
    end
  end
end
