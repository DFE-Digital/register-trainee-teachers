# frozen_string_literal: true

module Hesa
  module CodeSets
    module IttQualificationAims
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/qlaim
      MAPPING = {
        "007" => "BA",
        "008" => "BA (Hons)",
        "001" => "BEd",
        "002" => "BEd (Hons)",
        "003" => "BSc",
        "004" => "BSc (Hons)",
        "020" => "Postgraduate Certificate in Education",
        "021" => "Postgraduate Diploma in Education",
        "028" => "Undergraduate Master of Teaching",
        "031" => "Professional Graduate Certificate in Education",
        "032" => "Masters, not by research",
      }.freeze
    end
  end
end
