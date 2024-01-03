# frozen_string_literal: true

module Trainees
  class FindPotentialDuplicates < FindDuplicates
    def call
      potential_duplicates
    end
  end
end
