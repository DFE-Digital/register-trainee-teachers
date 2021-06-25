# frozen_string_literal: true

require "rails_helper"

module Diversities
  describe FormValidator do
    let(:trainee) { create(:trainee, :with_diversity_information) }
    let(:disclosure) { instance_double(DisclosureForm, valid?: true) }
    let(:ethnic_group) { instance_double(EthnicGroupForm, valid?: true) }
    let(:ethnic_background) { instance_double(EthnicBackgroundForm, valid?: true) }
    let(:disability_disclosure) { instance_double(DisabilityDisclosureForm, valid?: true) }
    let(:disability_detail_form) { instance_double(DisabilityDetailForm, valid?: true) }

    subject { described_class.new(trainee) }

    describe "validations" do
      context "when disclosed and all diversity forms valid" do
        before do
          expect(DisclosureForm).to receive(:new).and_return(disclosure)
          expect(EthnicGroupForm).to receive(:new).and_return(ethnic_group)
          expect(EthnicBackgroundForm).to receive(:new).and_return(ethnic_background)
          expect(DisabilityDisclosureForm).to receive(:new).and_return(disability_disclosure)
          expect(DisabilityDetailForm).to receive(:new).and_return(disability_detail_form)
        end

        it { is_expected.to be_valid }
      end

      context "when disclosure is valid and the value is 'diversity_not_disclosed'" do
        let(:trainee) { build(:trainee, :diversity_not_disclosed, ethnic_group: nil, ethnic_background: nil, disability_disclosure: nil) }

        it { is_expected.to be_valid }
      end

      context "when disclosure is valid and a dependent sub form is invalid" do
        before do
          trainee.ethnic_group = nil
        end

        it "returns an error for that sub form" do
          subject.valid?

          expect(subject.errors[:ethnic_group_section]).to include(
            I18n.t(
              "activemodel.errors.models.diversities/form_validator.attributes.ethnic_group_section.not_valid",
            ),
          )
        end
      end
    end
  end
end
