# frozen_string_literal: true

require "rails_helper"

module Schools
  describe FormValidator do
    subject { described_class.new(trainee) }

    describe "validations" do
      context "with a school_direct_tuition_fee trainee", "feature_routes.school_direct_tuition_fee": true do
        let(:trainee) { build(:trainee, :school_direct_tuition_fee) }
        let(:training_partner_form) { instance_double(Partners::TrainingPartnerForm, fields: nil, lead_partner_id: nil) }

        before do
          allow(Partners::TrainingPartnerForm).to receive(:new).and_return(training_partner_form)
        end

        context "when TrainingPartnerForm is valid" do
          before do
            allow(training_partner_form).to receive(:valid?).and_return(true)
          end

          it { is_expected.to be_valid }
        end

        context "when TrainingPartnerForm is invalid" do
          before do
            allow(training_partner_form).to receive(:valid?).and_return(false)
          end

          it "returns an error for the lead_partner_id key" do
            subject.valid?

            expect(subject.errors[:lead_partner_id]).to include(
              I18n.t(
                "activemodel.errors.models.schools/form_validator.attributes.lead_partner_id.not_valid",
              ),
            )
          end
        end
      end

      context "with a school_direct_salaried trainee", "feature_routes.school_direct_salaried": true do
        let(:trainee) { build(:trainee, :school_direct_salaried) }
        let(:training_partner_form) { instance_double(Partners::TrainingPartnerForm, fields: nil, lead_partner_id: nil) }
        let(:employing_school_form) { instance_double(Schools::EmployingSchoolForm, fields: nil, employing_school_id: nil) }

        before do
          allow(Partners::TrainingPartnerForm).to receive(:new).and_return(training_partner_form)
          allow(Schools::EmployingSchoolForm).to receive(:new).and_return(employing_school_form)
        end

        context "when TrainingPartnerForm is valid" do
          before do
            allow(training_partner_form).to receive(:valid?).and_return(true)
          end

          context "and EmployingSchoolForm is valid" do
            before do
              allow(employing_school_form).to receive(:valid?).and_return(true)
            end

            it { is_expected.to be_valid }
          end

          context "and EmployingSchoolForm is invalid" do
            before do
              allow(employing_school_form).to receive(:valid?).and_return(false)
            end

            it "returns an error for the employing_school_id key" do
              subject.valid?

              expect(subject.errors[:employing_school_id]).to include(
                I18n.t(
                  "activemodel.errors.models.schools/form_validator.attributes.employing_school_id.not_valid",
                ),
              )
            end
          end
        end

        context "when TrainingPartnerForm is invalid" do
          before do
            allow(training_partner_form).to receive(:valid?).and_return(false)
          end

          context "and EmployingSchoolForm is valid" do
            before do
              allow(employing_school_form).to receive(:valid?).and_return(true)
            end

            it "returns an error for the lead_partner_id key" do
              subject.valid?

              expect(subject.errors[:lead_partner_id]).to include(
                I18n.t(
                  "activemodel.errors.models.schools/form_validator.attributes.lead_partner_id.not_valid",
                ),
              )
            end
          end

          context "and EmployingSchoolForm is invalid" do
            before do
              allow(employing_school_form).to receive(:valid?).and_return(false)
            end

            it "returns errors for the lead_partner_id and the employing_school_id key" do
              subject.valid?

              expect(subject.errors[:employing_school_id]).to include(
                I18n.t(
                  "activemodel.errors.models.schools/form_validator.attributes.employing_school_id.not_valid",
                ),
              )
              expect(subject.errors[:lead_partner_id]).to include(
                I18n.t(
                  "activemodel.errors.models.schools/form_validator.attributes.lead_partner_id.not_valid",
                ),
              )
            end
          end
        end
      end

      describe "#missing_fields" do
        let(:trainee) { build(:trainee, :school_direct_tuition_fee) }

        subject { described_class.new(trainee).missing_fields }

        context "when valid" do
          it { is_expected.to eq([[]]) }
        end

        context "with invalid TrainingPartnerForm", "feature_routes.school_direct_tuition_fee": true do
          let(:training_partner_form) do
            instance_double(
              Partners::TrainingPartnerForm,
              fields: nil,
              lead_partner_id: nil,
              non_search_validation: true,
              errors: double(attribute_names: [:lead_partner_id]),
            )
          end

          before do
            allow(Partners::TrainingPartnerForm).to receive(:new).and_return(training_partner_form)
            allow(training_partner_form).to receive(:valid?).and_return(false)
          end

          it { is_expected.to include([:lead_partner_id]) }

          context "with invalid TrainingPartnerForm and EmployingSchoolForm form", "feature_routes.school_direct_salaried": true, "feature_routes.school_direct_tuition_fee": true do
            let(:employing_school_form) do
              instance_double(
                Schools::EmployingSchoolForm,
                fields: nil,
                employing_school_id: nil,
                non_search_validation: true,
                errors: double(attribute_names: [:employing_school_id]),
              )
            end

            let(:trainee) { build(:trainee, :school_direct_salaried) }

            before do
              allow(Schools::EmployingSchoolForm).to receive(:new).and_return(employing_school_form)
              allow(employing_school_form).to receive(:valid?).and_return(false)
            end

            it { is_expected.to include(%i[lead_partner_id employing_school_id]) }
          end
        end
      end
    end
  end
end
