# frozen_string_literal: true

require "rails_helper"

module Withdrawal
  describe FutureInterestForm, type: :model do
    let(:params) { { future_interest: "yes" } }
    let(:trainee) { create(:trainee) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      let(:inclusion_values) do
        %w[yes no unknown]
      end

      it { is_expected.to validate_inclusion_of(:future_interest).in_array(inclusion_values) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee withdrawal ID and future interest" do
        expect(form_store).to receive(:set).with(trainee.id, :future_interest, subject.fields)

        subject.stash
      end
    end
  end
end
