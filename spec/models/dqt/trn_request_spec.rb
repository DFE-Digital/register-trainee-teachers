# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe TrnRequest do
    subject { build(:dqt_trn_request) }

    it { is_expected.to be_valid }

    it { is_expected.to belong_to(:trainee) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:request_id) }
    end
  end
end
