# frozen_string_literal: true

module BulkImport
  module CodeSets
    module Routes
      MAPPING = {
        "schooldirectsalariedpg" => TRAINING_ROUTE_ENUMS[:school_direct_salaried],
        "schooldirecttuitionfeepg" => TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
        "teachingapprenticeshippg" => TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
        "providerledpg" => TRAINING_ROUTE_ENUMS[:provider_led_postgrad]
       }.freeze
    end
  end
end
