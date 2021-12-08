# frozen_string_literal: true

require "rails_helper"

module Funding
  describe FormValidator do
    subject { described_class.new(trainee) }

    describe "validations" do
      context "when no bursary would be available" do
        let(:trainee) { build(:trainee) }
        let(:training_initiative_form) { instance_double(Funding::TrainingInitiativesForm, fields: nil, training_initiative: nil) }
        let(:bursary_form) { instance_double(Funding::BursaryForm, fields: nil, valid?: true) }

        before do
          allow(Funding::TrainingInitiativesForm).to receive(:new).and_return(training_initiative_form)
          allow(Funding::BursaryForm).to receive(:new).and_return(bursary_form)
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

      context "when tiered bursary is available" do
        let(:trainee) { create(:trainee, :early_years_postgrad) }
        let(:training_initiative_form) { instance_double(Funding::TrainingInitiativesForm, fields: nil, training_initiative: nil, valid?: true) }

        before do
          allow(Funding::TrainingInitiativesForm).to receive(:new).and_return(training_initiative_form)
        end

        it { is_expected.not_to be_valid }

        context "and a tier has been selected" do
          let(:trainee) { create(:trainee, :early_years_postgrad, :with_tiered_bursary) }

          it { is_expected.to be_valid }
        end

        context "and no bursary has been selected" do
          let(:trainee) { create(:trainee, :early_years_postgrad, applying_for_bursary: false) }

          it { is_expected.to be_valid }
        end
      end

      context "when funding method is available" do
        let(:allocation_subject) { create(:allocation_subject) }
        let(:subject_specialism) { create(:subject_specialism, allocation_subject: allocation_subject) }

        let(:trainee) do
          create(:trainee,
                 :with_start_date,
                 :with_study_mode_and_course_dates,
                 training_route: funding_method.training_route.to_sym,
                 course_subject_one: subject_specialism.name)
        end

        let(:training_initiative_form) { instance_double(Funding::TrainingInitiativesForm, fields: nil, training_initiative: nil) }
        let(:bursary_form) do
          instance_double(Funding::BursaryForm, fields: nil, applying_for_bursary: nil, applying_for_grant: nil)
        end

        before do
          create(:funding_method_subject, allocation_subject: allocation_subject, funding_method: funding_method)
          allow(Funding::TrainingInitiativesForm).to receive(:new).and_return(training_initiative_form)
          allow(Funding::BursaryForm).to receive(:new).and_return(bursary_form)
        end

        %i[bursary grant].each do |funding_type|
          context "when funding type #{funding_type} is available" do
            let(:funding_method) { create(:funding_method, funding_type, training_route: :provider_led_postgrad) }

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

                let(:applying_for_funding_type_error_key) { "applying_for_#{funding_type}".to_sym }
                let(:applying_for_funding_type_error_message_key) do
                  "activemodel.errors.models.funding/form_validator.attributes.#{applying_for_funding_type_error_key}.inclusion"
                end

                it "returns an error for the applying_for_#{funding_type} key" do
                  subject.valid?

                  expect(subject.errors[applying_for_funding_type_error_key]).to include(
                    I18n.t(applying_for_funding_type_error_message_key),
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

                let(:applying_for_funding_type_error_key) { "applying_for_#{funding_type}".to_sym }
                let(:applying_for_funding_type_error_message_key) do
                  "activemodel.errors.models.funding/form_validator.attributes.#{applying_for_funding_type_error_key}.inclusion"
                end

                it "returns errors for the training_initiative and the applying_for_#{funding_type} key" do
                  subject.valid?

                  expect(subject.errors[applying_for_funding_type_error_key]).to include(
                    I18n.t(applying_for_funding_type_error_message_key),
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
          allow(FundingManager).to receive(:new).with(trainee).and_return(double(can_apply_for_bursary?: true))
        end

        it { is_expected.to eq([%i[training_initiative funding_type]]) }
      end
    end
  end
end
