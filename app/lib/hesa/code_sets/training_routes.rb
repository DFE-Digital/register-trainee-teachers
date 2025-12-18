# frozen_string_literal: true

module Hesa
  module CodeSets
    module TrainingRoutes
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      MAPPING = {
        "02" => ReferenceData::TRAINING_ROUTES.school_direct_tuition_fee.name,
        "03" => ReferenceData::TRAINING_ROUTES.school_direct_salaried,
        "09" => ReferenceData::TRAINING_ROUTES.opt_in_undergrad,
        "10" => ReferenceData::TRAINING_ROUTES.pg_teaching_apprenticeship,
        "11" => ReferenceData::TRAINING_ROUTES.provider_led_undergrad,
        "12" => ReferenceData::TRAINING_ROUTES.provider_led_postgrad,

      }.freeze
    end
  end
end
