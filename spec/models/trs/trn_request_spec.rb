# frozen_string_literal: true

require "rails_helper"

module Trs
  describe TrnRequest do
    subject { build(:trs_trn_request) }

    it { is_expected.to be_valid }

    it { is_expected.to belong_to(:trainee) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:request_id) }
    end

    describe "#days_waiting" do
      let(:trn_request) { create(:trs_trn_request, created_at: 2.days.ago) }

      it "returns the number of days since the request was created" do
        expect(trn_request.days_waiting).to eq(2)
      end
    end
  end
end
