# frozen_string_literal: true

require "rails_helper"

module Funding
  describe FormValidator do
    subject { described_class.new(trainee) }

    describe "validations" do
      context "when no bursary would be available" do
        let(:trainee) { build(:trainee) }
        let(:training_initiative_form) { instance_double(Funding::TrainingInitiativesForm, fields: nil, training_initiative: nil) }

        before do
          allow(Funding::TrainingInitiativesForm).to receive(:new).and_return(training_initiative_form)
        end

        context "when TrainingInitiativesForm is valid" do
          before do
            allow(training_initiative_form).to receive(:valid?).and_return(true)
          end

          it { is_expected.to be_valid }
        end

        context "when TrainingInitiativesForm is invalid" do
          before do
            allow(training_initiative_form).to receive(:valid?).and_return(false)
          end

          it "returns an error for the training_initiative key" do
            subject.valid?

            expect(subject.errors[:training_initiative]).to include(
              I18n.t(
                "activemodel.errors.models.funding/form_validator.attributes.training_initiative.blank",
              ),
            )
          end
        end
      end

      context "when a bursary is available" do
        let(:allocation_subject) { create(:allocation_subject) }
        let(:subject_specialism) { create(:subject_specialism, allocation_subject: allocation_subject) }
        let(:bursary) { create(:bursary, training_route: :provider_led_postgrad) }
        let(:trainee) { create(:trainee, training_route: bursary.training_route.to_sym, course_subject_one: subject_specialism.name) }

        let(:training_initiative_form) { instance_double(Funding::TrainingInitiativesForm, fields: nil, training_initiative: nil) }
        let(:bursary_form) { instance_double(Funding::BursaryForm, fields: nil, applying_for_bursary: nil) }

        before do
          create(:bursary_subject, allocation_subject: allocation_subject, bursary: bursary)
          allow(Funding::TrainingInitiativesForm).to receive(:new).and_return(training_initiative_form)
          allow(Funding::BursaryForm).to receive(:new).and_return(bursary_form)
        end

        context "when TrainingInitiativesForm is valid" do
          before do
            allow(training_initiative_form).to receive(:valid?).and_return(true)
          end

          context "and BursaryForm is valid" do
            before do
              allow(bursary_form).to receive(:valid?).and_return(true)
            end

            it { is_expected.to be_valid }
          end

          context "and BursaryForm is invalid" do
            before do
              allow(bursary_form).to receive(:valid?).and_return(false)
            end

            it "returns an error for the applying_for_bursary key" do
              subject.valid?

              expect(subject.errors[:applying_for_bursary]).to include(
                I18n.t(
                  "activemodel.errors.models.funding/form_validator.attributes.applying_for_bursary.inclusion",
                ),
              )
            end
          end
        end

        context "when TrainingInitiativesForm is invalid" do
          before do
            allow(training_initiative_form).to receive(:valid?).and_return(false)
          end

          context "and BursaryForm is valid" do
            before do
              allow(bursary_form).to receive(:valid?).and_return(true)
            end

            it "returns an error for the training_initiative key" do
              subject.valid?

              expect(subject.errors[:training_initiative]).to include(
                I18n.t(
                  "activemodel.errors.models.funding/form_validator.attributes.training_initiative.blank",
                ),
              )
            end
          end

          context "and BursaryForm is invalid" do
            before do
              allow(bursary_form).to receive(:valid?).and_return(false)
            end

            it "returns errors for the training_initiative and the applying_for_bursary key" do
              subject.valid?

              expect(subject.errors[:applying_for_bursary]).to include(
                I18n.t(
                  "activemodel.errors.models.funding/form_validator.attributes.applying_for_bursary.inclusion",
                ),
              )
              expect(subject.errors[:training_initiative]).to include(
                I18n.t(
                  "activemodel.errors.models.funding/form_validator.attributes.training_initiative.blank",
                ),
              )
            end
          end
        end
      end
    end

    describe "#missing_fields" do
      let(:trainee) { build(:trainee) }

      subject { described_class.new(trainee).missing_fields }

      context "when valid" do
        let(:trainee) { build(:trainee, :with_funding, applying_for_bursary: false) }

        it { is_expected.to eq([[]]) }
      end

      context "with invalid TrainingInitiativesForm form" do
        it { is_expected.to eq([[:training_initiative]]) }
      end

      context "with invalid TrainingInitiativesForm and Bursary form" do
        before do
          allow(trainee).to receive(:bursary_amount).and_return(1)
        end

        it { is_expected.to eq([%i[training_initiative applying_for_bursary]]) }
      end
    end
  end
end
