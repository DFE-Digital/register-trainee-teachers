# frozen_string_literal: true

module Hesa
  module CodeSets
    module IttQualificationAims
      BA = "BA"
      BA_HONS = "BA (Hons)"
      BED = "BEd"
      BED_HONS = "BEd (Hons)"
      BSC = "BSc"
      BSC_HONS = "BSc (Hons)"
      UNDERGRAD_MASTER_OF_TEACHING = "Undergraduate Master of Teaching"

      UNDERGRAD_AIMS = [BA, BA_HONS, BED, BED_HONS, BSC, BSC_HONS, UNDERGRAD_MASTER_OF_TEACHING].freeze

      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      # https://www.hesa.ac.uk/collection/c22053/e/qlaim
      MAPPING = {
        "001" => BED,
        "002" => BED_HONS,
        "020" => "Postgraduate Certificate in Education",
        "021" => "Postgraduate Diploma in Education",
        "028" => UNDERGRAD_MASTER_OF_TEACHING,
        "031" => "Professional Graduate Certificate in Education",
        "032" => "Masters, not by research",
        "099" => "Bachelor of Science with intercalated PGCE",
        "216" => "Master of Mathematics (MMATH)",
        "217" => "Master of Research (MRES)",
        "218" => "Master in Science (MSCI)",
        "307" => "Doctor of Education (EDD)",
      }.freeze
    end
  end
end
