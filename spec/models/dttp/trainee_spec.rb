# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe Trainee do
    subject { build(:dttp_trainee) }

    it { is_expected.to be_valid }

    describe "validations" do
      it { is_expected.to validate_presence_of(:response) }
    end
  end
end
