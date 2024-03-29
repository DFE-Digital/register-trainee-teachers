# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe BursaryDetail do
    subject { build(:dttp_bursary_detail) }

    it { is_expected.to be_valid }

    describe "validations" do
      it { is_expected.to validate_presence_of(:response) }
    end
  end
end
