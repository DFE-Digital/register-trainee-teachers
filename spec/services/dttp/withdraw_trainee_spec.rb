# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe WithdrawTrainee do
    include_examples "dttp trainee update", Params::PlacementOutcomes::Withdrawn
  end
end
