# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TraineeSummaryRowAmount do
    describe "associations" do
      it { is_expected.to belong_to(:row) }
    end
  end
end
