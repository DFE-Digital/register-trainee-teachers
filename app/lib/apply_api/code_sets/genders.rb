# frozen_string_literal: true

module ApplyApi
  module CodeSets
    module Genders
      MAPPING = {
        "male" => Trainee.sexes[:male],
        "female" => Trainee.sexes[:female],
        "intersex" => Trainee.sexes[:other],
        "Prefer not to say" => Trainee.sexes[:gender_not_provided],
        "" => Trainee.sexes[:gender_not_provided],
      }.freeze
    end
  end
end
