# frozen_string_literal: true

module DegreeSerializer
  class V01
    def initialize(degree)
      @degree = degree
    end

    def as_hash
      @degree.attributes
    end
  end
end
