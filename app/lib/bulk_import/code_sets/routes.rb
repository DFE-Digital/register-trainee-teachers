# frozen_string_literal: true

module BulkImport
  module CodeSets
    module Routes
      MAPPING = {
        "graduateentryroute" => TRAINING_ROUTE_ENUMS[:early_years_postgrad],
        "eygraduateentrypg" => TRAINING_ROUTE_ENUMS[:early_years_postgrad],
        "eygraduateemploymentbasedpg" => TRAINING_ROUTE_ENUMS[:early_years_salaried],
        "graduateemploymentbasedroute" => TRAINING_ROUTE_ENUMS[:early_years_salaried],
        "providerledpg" => TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        "schooldirectsalariedpg" => TRAINING_ROUTE_ENUMS[:school_direct_salaried],
        "schooldirecttuitionfeepg" => TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
        "teachingapprenticeshippg" => TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
      }.freeze
    end
  end
end
