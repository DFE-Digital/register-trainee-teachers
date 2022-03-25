# frozen_string_literal: true

module Hesa
  module CodeSets
    module Genders
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/sexid
      MAPPING = {
        "1" => Trainee.genders[:male],
        "2" => Trainee.genders[:female],
        "3" => Trainee.genders[:other],
      }.freeze
    end
  end
end
