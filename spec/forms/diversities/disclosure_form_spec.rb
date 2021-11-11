# frozen_string_literal: true

require "rails_helper"

module Diversities
  describe DisclosureForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, :diversity_disclosed) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:diversity_disclosure) }
      it { is_expected.to validate_inclusion_of(:diversity_disclosure).in_array(Diversities::DIVERSITY_DISCLOSURE_ENUMS.values) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and diversity_disclosure" do
        expect(form_store).to receive(:set).with(trainee.id, :diversity_disclosure, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      before do
        allow(form_store).to receive(:get).and_return({ "diversity_disclosure" => diversity_disclosure_value })
        allow(form_store).to receive(:set).with(trainee.id, :diversity_disclosure, nil)
      end

      context "diversity not disclosed" do
        let(:diversity_disclosure_value) { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] }

        it "saves the diversity disclosure value" do
          expect { subject.save! }.to change(trainee, :diversity_disclosure).to(diversity_disclosure_value)
        end

        it "saves the disability disclosure as not provided" do
          expect { subject.save! }.to change(trainee, :disability_disclosure).to(
            Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided],
          )
        end
      end

      context "diversity changed to disclosed" do
        let(:trainee) do
          create(
            :trainee,
            :diversity_not_disclosed,
            disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided],
          )
        end

        let(:diversity_disclosure_value) { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] }

        it "resets the disability disclosure" do
          expect { subject.save! }.to change(trainee, :disability_disclosure).to(nil)
        end
      end
    end
  end
end
