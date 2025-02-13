# frozen_string_literal: true

require "rails_helper"

RSpec.describe TraineeWithdrawalReason do
  describe "associations" do
    it { is_expected.to belong_to(:trainee).touch(true).optional(true) }
    it { is_expected.to belong_to(:withdrawal_reason) }
    it { is_expected.to belong_to(:trainee_withdrawal).optional(true) }
  end
end
