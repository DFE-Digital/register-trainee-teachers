# frozen_string_literal: true

require "rails_helper"

describe TraineeDisability do
  subject { build(:trainee_disability) }

  describe "associations" do
    it { is_expected.to belong_to(:trainee) }
    it { is_expected.to belong_to(:disability) }
  end
end
