# frozen_string_literal: true

module Hesa
  module CodeSets
    module FundCodes
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/fundcode
      MAPPING = {
        "2" => "Not fundable by funding council/body",
        "7" => "Eligible for funding from the DfE",
      }.freeze
    end
  end
end
