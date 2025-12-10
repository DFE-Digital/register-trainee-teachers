# frozen_string_literal: true

module Hesa
  module CodeSets
    module TrainingRoutes
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      MAPPING = {
        "02" => "school_direct_tuition_fee",
        "03" => "school_direct_salaried",
        "09" => "opt_in_undergrad",
        "10" => "pg_teaching_apprenticeship",
        "11" => "provider_led_undergrad",
        "12" => "provider_led_postgrad",
        "14" => "teacher_degree_apprenticeship",
      }.freeze
    end
  end
end
