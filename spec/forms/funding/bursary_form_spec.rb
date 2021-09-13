# frozen_string_literal: true

require "rails_helper"

module Funding
  describe BursaryForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, applying_for_bursary: true) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      let(:inclusion_values) do
        Trainee.bursary_tiers.keys + %w[bursary scholarship none]
      end

      it { is_expected.to validate_inclusion_of(:funding_type).in_array(inclusion_values) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and bursary" do
        expect(form_store).to receive(:set).with(trainee.id, :bursary, subject.fields.except(:funding_type))

        subject.stash
      end
    end

    describe "#save!" do
      let(:applying_for_bursary) { false }

      before do
        allow(form_store).to receive(:get).and_return({ "applying_for_bursary" => applying_for_bursary })
        allow(form_store).to receive(:set).with(trainee.id, :bursary, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee.reload, :applying_for_bursary).to(false)
      end
    end

    describe "#funding_type" do
      describe "set funding_type from activerecord" do
        describe "bursary type" do
          let(:trainee) { create(:trainee, applying_for_bursary: true, bursary_tier: nil, applying_for_scholarship: false) }

          it { expect(subject.funding_type).to eq(FUNDING_TYPE_ENUMS[:bursary]) }
        end

        describe "tiered bursary type" do
          let(:trainee) { create(:trainee, applying_for_bursary: true, bursary_tier: "tier_two", applying_for_scholarship: false) }

          it { expect(Trainee.bursary_tiers.keys).to include(subject.funding_type) }
        end

        describe "scholarship type" do
          let(:trainee) { create(:trainee, applying_for_bursary: false, bursary_tier: nil, applying_for_scholarship: true) }

          it { expect(subject.funding_type).to eq(FUNDING_TYPE_ENUMS[:scholarship]) }
        end

        describe "no funding type" do
          let(:trainee) { create(:trainee, applying_for_bursary: false, bursary_tier: nil, applying_for_scholarship: false) }

          it { expect(subject.funding_type).to eq(Funding::BursaryForm::NONE_TYPE) }
        end

        describe "funding type not set" do
          let(:trainee) { create(:trainee, applying_for_bursary: nil, bursary_tier: nil, applying_for_scholarship: nil) }

          it { expect(subject.funding_type).to be_nil }
        end
      end

      describe "set funding_type from params" do
        let(:trainee) { create(:trainee, applying_for_bursary: nil, bursary_tier: nil, applying_for_scholarship: nil) }

        describe "funding type not set" do
          it { expect(subject.funding_type).to be_nil }
          it { expect(subject.applying_for_bursary).to be_nil }
          it { expect(subject.applying_for_scholarship).to be_nil }
          it { expect(subject.bursary_tier).to be_nil }
        end

        describe "bursary type" do
          let(:params) { { funding_type: FUNDING_TYPE_ENUMS[:bursary] } }

          it { expect(subject.funding_type).to eq(FUNDING_TYPE_ENUMS[:bursary]) }
          it { expect(subject.applying_for_bursary).to be_truthy }
          it { expect(subject.applying_for_scholarship).to be_falsey }
          it { expect(subject.bursary_tier).to be_nil }
        end

        describe "tiered bursary type" do
          let(:params) { { funding_type: Trainee.bursary_tiers.keys[0] } }

          it { expect(subject.funding_type).to eq(params[:funding_type]) }
          it { expect(subject.applying_for_bursary).to be_truthy }
          it { expect(subject.applying_for_scholarship).to be_falsey }
          it { expect(subject.bursary_tier).to be(Trainee.bursary_tiers.keys[0]) }
        end

        describe "scholarship type" do
          let(:params) { { funding_type: FUNDING_TYPE_ENUMS[:scholarship] } }

          it { expect(subject.funding_type).to eq(FUNDING_TYPE_ENUMS[:scholarship]) }
          it { expect(subject.applying_for_bursary).to be_falsey }
          it { expect(subject.applying_for_scholarship).to be_truthy }
          it { expect(subject.bursary_tier).to be_nil }
        end

        describe "no funding type" do
          let(:params) { { funding_type: Funding::BursaryForm::NONE_TYPE } }

          it { expect(subject.funding_type).to eq(Funding::BursaryForm::NONE_TYPE) }
          it { expect(subject.applying_for_bursary).to be_falsey }
          it { expect(subject.applying_for_scholarship).to be_falsey }
          it { expect(subject.bursary_tier).to be_nil }
        end
      end
    end
  end
end
