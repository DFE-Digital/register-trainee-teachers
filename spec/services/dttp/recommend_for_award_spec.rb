# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RecommendForAward do
    include_examples "dttp trainee update", Params::PlacementOutcomes::Qts
  end
end
