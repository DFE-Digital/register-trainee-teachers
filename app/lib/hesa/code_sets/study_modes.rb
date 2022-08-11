# frozen_string_literal: true

module Hesa
  module CodeSets
    module StudyModes
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      # https://www.hesa.ac.uk/collection/c22053/e/mode
      MAPPING = {
        "01" => TRAINEE_STUDY_MODE_ENUMS["full_time"],
        "02" => TRAINEE_STUDY_MODE_ENUMS["full_time"],
        "31" => TRAINEE_STUDY_MODE_ENUMS["part_time"],
        "63" => TRAINEE_STUDY_MODE_ENUMS["full_time"],
        "64" => TRAINEE_STUDY_MODE_ENUMS["part_time"],
      }.freeze
    end
  end
end
