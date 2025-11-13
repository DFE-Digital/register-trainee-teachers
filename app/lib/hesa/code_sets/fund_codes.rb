# frozen_string_literal: true

module Hesa
  module CodeSets
    module FundCodes
      NOT_ELIGIBLE = "2"
      ELIGIBLE = "7"

      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      # https://www.hesa.ac.uk/collection/c22053/e/fundcode
      MAPPING = {
        NOT_ELIGIBLE => "Not fundable by funding council/body",
        ELIGIBLE => "Eligible for funding from the DfE",
      }.freeze

      NO_FUND_CODE_PROVIDED = "No fund code provided"
    end
  end
end
