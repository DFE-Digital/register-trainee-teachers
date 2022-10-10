# frozen_string_literal: true

module ApplyApi
  module CodeSets
    module Genders
      # intersex is needed until it is no longer possible to received the value from
      # apply, which should be the next recruitment cycle - 2024.

      MAPPING = {
        "male" => Trainee.sexes[:male],
        "female" => Trainee.sexes[:female],
        "intersex" => Trainee.sexes[:other],
        "other" => Trainee.sexes[:other],
        "Prefer not to say" => Trainee.sexes[:sex_not_provided],
        "" => Trainee.sexes[:sex_not_provided],
      }.freeze
    end
  end
end
