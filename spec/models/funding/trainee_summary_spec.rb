# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TraineeSummary do
    describe "associations" do
      it { is_expected.to have_many(:rows) }
    end
  end
end
