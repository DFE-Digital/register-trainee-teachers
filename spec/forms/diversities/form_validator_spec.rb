# frozen_string_literal: true

require "rails_helper"

module Diversities
  describe FormValidator do
    let(:trainee) do
      build(:trainee, diversity_disclosure: nil, ethnic_group: nil, ethnic_background: nil, disability_disclosure: nil)
    end

    subject { described_class.new(trainee) }

    describe "validations" do
      context "when trainee has disclosed diversity" do
        let(:disclosure) { instance_double(DisclosureForm) }

        before do
          trainee.diversity_disclosure = DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
          expect(DisclosureForm).to receive(:new).and_return(disclosure)
        end

        context "when DisclosureForm is valid" do
          let(:validity) { true }

          before do
            allow(disclosure).to receive(:valid?).and_return(true)
          end

          it { is_expected.to be_valid }

          context "ethnic group" do
            let(:ethnic_group) { instance_double(EthnicGroupForm) }

            before do
              trainee.ethnic_group = ETHNIC_GROUP_ENUMS.values.sample
              expect(EthnicGroupForm).to receive(:new).and_return(ethnic_group)
            end

            context "when EthnicGroupForm is valid" do
              before do
                allow(ethnic_group).to receive(:valid?).and_return(true)
              end

              it { is_expected.to be_valid }

              context "ethnic background" do
                let(:ethnic_background) { instance_double(EthnicBackgroundForm) }

                before do
                  trainee.ethnic_background = "some background"
                  expect(EthnicBackgroundForm).to receive(:new).and_return(ethnic_background)
                end

                context "when EthnicBackgroundForm is valid" do
                  before do
                    allow(ethnic_background).to receive(:valid?).and_return(true)
                  end

                  it { is_expected.to be_valid }
                end

                context "when EthnicBackgroundForm is invalid" do
                  before do
                    allow(ethnic_background).to receive(:valid?).and_return(false)
                  end

                  it "returns an error for the ethnic_background_section key" do
                    subject.valid?

                    expect(subject.errors[:ethnic_background_section]).to include(
                      I18n.t(
                        "activemodel.errors.models.diversities/form_validator.attributes.ethnic_background_section.not_valid",
                      ),
                    )
                  end
                end
              end
            end

            context "when EthnicGroupForm is invalid" do
              before do
                allow(ethnic_group).to receive(:valid?).and_return(false)
              end

              it "returns an error for the ethnic_group_section key" do
                subject.valid?

                expect(subject.errors[:ethnic_group_section]).to include(
                  I18n.t(
                    "activemodel.errors.models.diversities/form_validator.attributes.ethnic_group_section.not_valid",
                  ),
                )
              end
            end
          end

          context "disability disclosure" do
            let(:disability_disclosure) { instance_double(DisabilityDisclosureForm) }

            before do
              trainee.disability_disclosure = DISABILITY_DISCLOSURE_ENUMS[:no_disability]
              expect(DisabilityDisclosureForm).to receive(:new).and_return(disability_disclosure)
            end

            context "when DisabilityDisclosureForm is valid" do
              before do
                allow(disability_disclosure).to receive(:valid?).and_return(true)
              end

              it { is_expected.to be_valid }

              context "when trainee is disabled" do
                let(:disability_detail) { instance_double(DisabilityDetailForm) }

                before do
                  trainee.disability_disclosure = DISABILITY_DISCLOSURE_ENUMS[:disabled]
                  expect(DisabilityDetailForm).to receive(:new).and_return(disability_detail)
                end

                context "when DisabilityDetailForm is valid" do
                  before do
                    allow(disability_detail).to receive(:valid?).and_return(true)
                  end

                  it { is_expected.to be_valid }
                end

                context "when DisabilityDetailForm is invalid" do
                  before do
                    allow(disability_detail).to receive(:valid?).and_return(false)
                  end

                  it "returns an error for the disability_ids key" do
                    subject.valid?

                    expect(subject.errors[:disability_ids]).to include(
                      I18n.t(
                        "activemodel.errors.models.diversities/form_validator.attributes.disability_ids.not_valid",
                      ),
                    )
                  end
                end
              end
            end

            context "when DisabilityDisclosureForm is invalid" do
              before do
                allow(disability_disclosure).to receive(:valid?).and_return(false)
              end

              it "returns an error for the disability_disclosure_section key" do
                subject.valid?

                expect(subject.errors[:disability_disclosure_section]).to include(
                  I18n.t(
                    "activemodel.errors.models.diversities/form_validator.attributes.disability_disclosure_section.not_valid",
                  ),
                )
              end
            end
          end
        end

        context "when DisclosureForm is valid and not disclosed" do
          before do
            trainee.diversity_disclosure = DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
            allow(disclosure).to receive(:valid?).and_return(true)
          end

          it { is_expected.to be_valid }
        end

        context "when DisclosureForm is invalid" do
          before do
            allow(disclosure).to receive(:valid?).and_return(false)
          end

          it "returns an error for the disclosure_section key" do
            subject.valid?

            expect(subject.errors[:disclosure_section]).to include(
              I18n.t(
                "activemodel.errors.models.diversities/form_validator.attributes.disclosure_section.not_valid",
              ),
            )
          end
        end
      end
    end
  end
end
