# frozen_string_literal: true

require "rails_helper"

module Withdrawal
  describe TriggerForm, type: :model do
    let(:params) { { trigger: } }
    let(:trigger) { "provider" }
    let(:trainee) { create(:trainee) }
    let(:trainee_withdrawal) { create(:trainee_withdrawal, :untriggered, trainee:) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).with(trainee.id, :trigger).and_return({ "trigger" => "provider" })
      allow(form_store).to receive(:get).with(trainee.id, :withdrawal_reasons).and_return({ reason_ids: [1, 2], another_reason: nil })
      allow(form_store).to receive(:set).with(trainee.id, :withdrawal_reasons, {}).and_return(true)
      allow(form_store).to receive(:set).with(trainee.id, :trigger, { trigger: }).and_return(true)
    end

    describe "validations" do
      let(:inclusion_values) do
        %w[provider trainee]
      end

      it { is_expected.to validate_inclusion_of(:trigger).in_array(inclusion_values) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee withdrawal ID and trigger" do
        expect(form_store).to receive(:set).with(trainee.id, :trigger, subject.fields)

        subject.stash
      end

      context "when stored trigger changes" do
        let(:trigger) { "trainee" }

        it "clears the withdrawal reasons information if the trigger changes" do
          expect(form_store).to receive(:set).with(trainee.id, :withdrawal_reasons, {})

          subject.stash
        end
      end

      context "when stored trigger does not change" do
        it "does not clear the withdrawal reasons information if the trigger changes" do
          expect(form_store).not_to receive(:set).with(trainee.id, :withdrawal_reasons, {})

          subject.stash
        end
      end
    end
  end
end
