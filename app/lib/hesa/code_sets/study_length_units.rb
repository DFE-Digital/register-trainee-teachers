# frozen_string_literal: true

module Hesa
  module CodeSets
    module StudyLengthUnits
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/unitlgth
      MAPPING = {
        "1" =>	"years",
        "2" =>	"months",
        "3" =>	"weeks",
        "4" =>	"days",
        "5" =>	"hours",
      }.freeze
    end
  end
end
