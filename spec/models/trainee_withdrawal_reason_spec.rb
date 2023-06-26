# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeWithdrawalReason do
  describe "associations" do
    it { is_expected.to belong_to(:trainee).touch(true) }
    it { is_expected.to belong_to(:withdrawal_reason) }
  end
end
