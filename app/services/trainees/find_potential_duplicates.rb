# frozen_string_literal: true

module Trainees
  class FindPotentialDuplicates < FindDuplicatesOfApplyApplication
    def call
      potential_duplicates
    end
  end
end
