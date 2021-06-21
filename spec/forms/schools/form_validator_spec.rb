# frozen_string_literal: true

require "rails_helper"

module Schools
  describe FormValidator do
    subject { described_class.new(trainee) }

    describe "validations" do
      context "with a school_direct_tuition_fee trainee", "feature_routes.school_direct_tuition_fee": true do
        let(:trainee) { build(:trainee, :school_direct_tuition_fee) }
        let(:lead_school_form) { instance_double(Schools::LeadSchoolForm, fields: nil, lead_school_id: nil) }

        before do
          allow(Schools::LeadSchoolForm).to receive(:new).and_return(lead_school_form)
        end

        context "when LeadSchoolForm is valid" do
          before do
            allow(lead_school_form).to receive(:valid?).and_return(true)
          end

          it { is_expected.to be_valid }
        end

        context "when LeadSchoolForm is invalid" do
          before do
            allow(lead_school_form).to receive(:valid?).and_return(false)
          end

          it "returns an error for the lead_school_id key" do
            subject.valid?

            expect(subject.errors[:lead_school_id]).to include(
              I18n.t(
                "activemodel.errors.models.schools/form_validator.attributes.lead_school_id.not_valid",
              ),
            )
          end
        end
      end

      context "with a school_direct_salaried trainee", "feature_routes.school_direct_salaried": true do
        let(:trainee) { build(:trainee, :school_direct_salaried) }
        let(:lead_school_form) { instance_double(Schools::LeadSchoolForm, fields: nil, lead_school_id: nil) }
        let(:employing_school_form) { instance_double(Schools::EmployingSchoolForm, fields: nil, employing_school_id: nil) }

        before do
          allow(Schools::LeadSchoolForm).to receive(:new).and_return(lead_school_form)
          allow(Schools::EmployingSchoolForm).to receive(:new).and_return(employing_school_form)
        end

        context "when LeadSchoolForm is valid" do
          before do
            allow(lead_school_form).to receive(:valid?).and_return(true)
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

        context "when LeadSchoolForm is invalid" do
          before do
            allow(lead_school_form).to receive(:valid?).and_return(false)
          end

          context "and EmployingSchoolForm is valid" do
            before do
              allow(employing_school_form).to receive(:valid?).and_return(true)
            end

            it "returns an error for the lead_school_id key" do
              subject.valid?

              expect(subject.errors[:lead_school_id]).to include(
                I18n.t(
                  "activemodel.errors.models.schools/form_validator.attributes.lead_school_id.not_valid",
                ),
              )
            end
          end

          context "and EmployingSchoolForm is invalid" do
            before do
              allow(employing_school_form).to receive(:valid?).and_return(false)
            end

            it "returns errors for the lead_school_id and the employing_school_id key" do
              subject.valid?

              expect(subject.errors[:employing_school_id]).to include(
                I18n.t(
                  "activemodel.errors.models.schools/form_validator.attributes.employing_school_id.not_valid",
                ),
              )
              expect(subject.errors[:lead_school_id]).to include(
                I18n.t(
                  "activemodel.errors.models.schools/form_validator.attributes.lead_school_id.not_valid",
                ),
              )
            end
          end
        end
      end
    end
  end
end
