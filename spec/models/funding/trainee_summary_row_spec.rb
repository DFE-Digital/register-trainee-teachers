# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TraineeSummaryRow do
    describe "associations" do
      it { is_expected.to belong_to(:trainee_summary) }
      it { is_expected.to have_many(:amounts) }
    end
  end
end
