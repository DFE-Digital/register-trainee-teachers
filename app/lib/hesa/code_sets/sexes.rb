# frozen_string_literal: true

module Hesa
  module CodeSets
    module Sexes
      # https://www.hesa.ac.uk/collection/c22053/e/sexid
      MAPPING = {
        "10" => ::Trainee.sexes[:female],
        "11" => ::Trainee.sexes[:male],
        "12" => ::Trainee.sexes[:other],
        "96" => ::Trainee.sexes[:prefer_not_to_say],
        "99" => ::Trainee.sexes[:sex_not_provided],
      }.freeze
    end
  end
end
