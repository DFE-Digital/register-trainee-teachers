# frozen_string_literal: true

require "rails_helper"

module Funding
  describe EligibilityForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, funding_eligibility: "eligible") }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get)
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:funding_eligibility) }
      it { is_expected.to validate_inclusion_of(:funding_eligibility).in_array(FUNDING_ELIGIBILITIES.values) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and funding_eligibility" do
        expect(form_store).to receive(:set).with(trainee.id, :funding_eligibility, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      let(:eligibility) { FUNDING_ELIGIBILITIES[:not_eligible] }

      before do
        allow(form_store).to receive(:get).and_return({ "funding_eligibility" => eligibility })
        allow(form_store).to receive(:set).with(trainee.id, :funding_eligibility, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :funding_eligibility).to(eligibility)
      end

      context "when funding eligibility changes" do
        let(:trainee) do
          create(:trainee,
                 funding_eligibility: "eligible",
                 applying_for_bursary: true,
                 applying_for_scholarship: false,
                 applying_for_grant: true,
                 bursary_tier: :tier_one)
        end
        let(:eligibility) { FUNDING_ELIGIBILITIES[:not_eligible] }

        it "clears funding method fields" do
          subject.save!

          trainee.reload
          expect(trainee.applying_for_bursary).to be_nil
          expect(trainee.applying_for_scholarship).to be_nil
          expect(trainee.applying_for_grant).to be_nil
          expect(trainee.bursary_tier).to be_nil
        end
      end

      context "when funding eligibility does not change" do
        let(:trainee) do
          create(:trainee,
                 funding_eligibility: "eligible",
                 applying_for_bursary: true)
        end
        let(:eligibility) { FUNDING_ELIGIBILITIES[:eligible] }

        it "does not clear funding method fields" do
          subject.save!

          trainee.reload
          expect(trainee.applying_for_bursary).to be true
        end
      end
    end
  end
end
