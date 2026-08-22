# frozen_string_literal: true

require "rails_helper"

module Schools
  describe AssessmentOnlyEmployingSchoolForm, type: :model do
    let(:trainee) { create(:trainee) }
    let(:form_store) { class_double(FormStore) }
    let(:school_id) { create(:school).id }
    let(:params) { { "employing_school_id" => school_id } }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
      allow(form_store).to receive(:set)
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields" do
        expect(form_store).to receive(:set).with(trainee.id, :employing_school, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      context "with a GIAS school" do
        it "saves the employing school" do
          expect { subject.save! }.to change(trainee, :employing_school_id).to(school_id)
        end
      end

      context "with a manual school" do
        let(:params) do
          {
            "employing_school_name" => "Oak House School",
            "employing_school_postcode" => "SW1A 1AA",
          }
        end

        it "saves the manual fields" do
          expect { subject.save! }.to change(trainee, :employing_school_name).to("Oak House School")
          expect(trainee.employing_school_id).to be_nil
          expect(trainee.employing_school_postcode).to eq("SW1A 1AA")
        end
      end

      context "when changing from a GIAS school to a manual school" do
        let(:trainee) { create(:trainee, employing_school_id: school_id) }
        let(:params) do
          {
            "employing_school_id" => school_id.to_s,
            "employing_school_name" => "Oak House School",
            "employing_school_postcode" => "SW1A 1AA",
          }
        end

        it "overrides the GIAS school with the manual details" do
          expect { subject.save! }.to change(trainee, :employing_school_id).to(nil)
          expect(trainee.employing_school_name).to eq("Oak House School")
          expect(trainee.employing_school_postcode).to eq("SW1A 1AA")
        end
      end

      context "when selecting a different GIAS school with leftover manual fields" do
        let(:other_school) { create(:school) }
        let(:trainee) { create(:trainee, employing_school_id: school_id) }
        let(:params) do
          {
            "employing_school_id" => other_school.id.to_s,
            "employing_school_name" => "Oak House School",
            "employing_school_postcode" => "SW1A 1AA",
          }
        end

        it "keeps the new GIAS school and clears the manual details" do
          subject.save!
          expect(trainee.employing_school_id).to eq(other_school.id)
          expect(trainee.employing_school_name).to be_nil
          expect(trainee.employing_school_postcode).to be_nil
        end
      end
    end

    context "with neither a GIAS school nor manual details" do
      let(:params) { { "query" => "" } }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:query]).to include(I18n.t("activemodel.errors.models.schools/assessment_only_employing_school_form.attributes.query.blank"))
      end
    end

    context "with a manual school but no postcode" do
      let(:params) { { "employing_school_name" => "Oak House School" } }

      it "requires a postcode" do
        expect(subject).not_to be_valid
        expect(subject.errors[:employing_school_postcode]).to be_present
      end
    end
  end
end
