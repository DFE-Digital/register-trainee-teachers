# frozen_string_literal: true

module ApplyApi
  module CodeSets
    module Genders
      MAPPING = {
        "male" => Trainee.genders[:male],
        "female" => Trainee.genders[:female],
        "intersex" => Trainee.genders[:other],
        "Prefer not to say" => Trainee.genders[:gender_not_provided],
        "" => Trainee.genders[:gender_not_provided],
      }.freeze
    end
  end
end
