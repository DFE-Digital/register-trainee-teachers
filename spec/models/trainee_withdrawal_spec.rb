# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeWithdrawal do
  describe "associations" do
    it { is_expected.to belong_to(:trainee) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:trigger).with_values(provider: "provider", trainee: "trainee").with_prefix(:triggered_by) }
    it { is_expected.to define_enum_for(:future_interest).with_values(yes: "yes", no: "no", unknown: "unknown").with_suffix }
  end
end
