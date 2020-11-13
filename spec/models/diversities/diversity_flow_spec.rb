require "rails_helper"

module Diversities
  describe DiversityFlow do
    let(:trainee) do
      build(:trainee, diversity_disclosure: nil, ethnic_group: nil, ethnic_background: nil, disability_disclosure: nil)
    end

    subject { described_class.new(trainee) }

    describe "validations" do
      context "when trainee has disclosed diversity" do
        let(:disclosure) { instance_double(Disclosure) }

        before do
          trainee.diversity_disclosure = DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
          expect(Disclosure).to receive(:new).and_return(disclosure)
        end

        context "when Disclosure is valid" do
          let(:validity) { true }

          before do
            allow(disclosure).to receive(:valid?).and_return(true)
          end

          it { is_expected.to be_valid }

          context "ethnic group" do
            let(:ethnic_group) { instance_double(EthnicGroup) }

            before do
              trainee.ethnic_group = ETHNIC_GROUP_ENUMS.values.sample
              expect(EthnicGroup).to receive(:new).and_return(ethnic_group)
            end

            context "when EthnicGroup is valid" do
              before do
                allow(ethnic_group).to receive(:valid?).and_return(true)
              end

              it { is_expected.to be_valid }

              context "ethnic background" do
                let(:ethnic_background) { instance_double(EthnicBackground) }

                before do
                  trainee.ethnic_background = "some background"
                  expect(EthnicBackground).to receive(:new).and_return(ethnic_background)
                end

                context "when EthnicBackground is valid" do
                  before do
                    allow(ethnic_background).to receive(:valid?).and_return(true)
                  end

                  it { is_expected.to be_valid }
                end

                context "when EthnicBackground is invalid" do
                  before do
                    allow(ethnic_background).to receive(:valid?).and_return(false)
                  end

                  it "returns an error for the ethnic_background_section key" do
                    subject.valid?

                    expect(subject.errors[:ethnic_background_section]).to include(
                      I18n.t(
                        "activemodel.errors.models.diversities/diversity_flow.attributes.ethnic_background_section.not_valid",
                      ),
                    )
                  end
                end
              end
            end

            context "when EthnicGroup is invalid" do
              before do
                allow(ethnic_group).to receive(:valid?).and_return(false)
              end

              it "returns an error for the ethnic_group_section key" do
                subject.valid?

                expect(subject.errors[:ethnic_group_section]).to include(
                  I18n.t(
                    "activemodel.errors.models.diversities/diversity_flow.attributes.ethnic_group_section.not_valid",
                  ),
                )
              end
            end
          end

          context "disability disclosure" do
            let(:disability_disclosure) { instance_double(DisabilityDisclosure) }

            before do
              trainee.disability_disclosure = DISABILITY_DISCLOSURE_ENUMS[:not_disabled]
              expect(DisabilityDisclosure).to receive(:new).and_return(disability_disclosure)
            end

            context "when DisabilityDisclosure is valid" do
              before do
                allow(disability_disclosure).to receive(:valid?).and_return(true)
              end

              it { is_expected.to be_valid }

              context "when trainee is disabled" do
                let(:disability_detail) { instance_double(DisabilityDetail) }

                before do
                  trainee.disability_disclosure = DISABILITY_DISCLOSURE_ENUMS[:disabled]
                  expect(DisabilityDetail).to receive(:new).and_return(disability_detail)
                end

                context "when DisabilityDetail is valid" do
                  before do
                    allow(disability_detail).to receive(:valid?).and_return(true)
                  end

                  it { is_expected.to be_valid }
                end

                context "when DisabilityDetail is invalid" do
                  before do
                    allow(disability_detail).to receive(:valid?).and_return(false)
                  end

                  it "returns an error for the disability_ids key" do
                    subject.valid?

                    expect(subject.errors[:disability_ids]).to include(
                      I18n.t(
                        "activemodel.errors.models.diversities/diversity_flow.attributes.disability_ids.not_valid",
                      ),
                    )
                  end
                end
              end
            end

            context "when DisabilityDisclosure is invalid" do
              before do
                allow(disability_disclosure).to receive(:valid?).and_return(false)
              end

              it "returns an error for the disability_disclosure_section key" do
                subject.valid?

                expect(subject.errors[:disability_disclosure_section]).to include(
                  I18n.t(
                    "activemodel.errors.models.diversities/diversity_flow.attributes.disability_disclosure_section.not_valid",
                  ),
                )
              end
            end
          end
        end

        context "when Disclosure is valid and not disclosed" do
          before do
            trainee.diversity_disclosure = DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
            allow(disclosure).to receive(:valid?).and_return(true)
          end

          it { is_expected.to be_valid }
        end

        context "when Disclosure is invalid" do
          before do
            allow(disclosure).to receive(:valid?).and_return(false)
          end

          it "returns an error for the disclosure_section key" do
            subject.valid?

            expect(subject.errors[:disclosure_section]).to include(
              I18n.t(
                "activemodel.errors.models.diversities/diversity_flow.attributes.disclosure_section.not_valid",
              ),
            )
          end
        end
      end
    end
  end
end
