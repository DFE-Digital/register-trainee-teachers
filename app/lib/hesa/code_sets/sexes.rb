# frozen_string_literal: true

module Hesa
  module CodeSets
    module Sexes
      # https://www.hesa.ac.uk/collection/c22053/e/sexid
      MAPPING = {
        "10" => Trainee.genders[:female],
        "11" => Trainee.genders[:male],
        "12" => Trainee.genders[:other],
        "96" => Trainee.genders[:prefer_not_to_say],
        "99" => Trainee.genders[:gender_not_provided],
      }.freeze
    end
  end
end
