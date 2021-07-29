# frozen_string_literal: true

require "rails_helper"

describe PersonalDetailsForm, type: :model do
  let(:trainee) { create(:trainee, gender: :male) }
  let(:form_store) { class_double(FormStore) }
  let(:french) { create(:nationality, name: "french") }
  let(:american) { create(:nationality, name: "american") }
  let(:irish) { create(:nationality, name: "irish") }
  let(:fields) do
    {
      "first_names" => "Millie",
      "middle_names" => "Schmeler",
      "last_name" => "Lehner",
      "gender" => "gender_not_provided",
      "day" => "11",
      "month" => "11",
      "year" => "1963",
      "other" => "1",
      "other_nationality1" => "French",
      "other_nationality1_raw" => "French",
      "other_nationality2" => "American",
      "other_nationality2_raw" => "American",
      "other_nationality3" => "Irish",
      "other_nationality3_raw" => "Irish",
      "nationality_names" => [french.name.titleize, american.name.titleize, irish.name.titleize],
    }
  end

  let(:params) { fields }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_names) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_inclusion_of(:gender).in_array(Trainee.genders.keys) }

    context "nationalities" do
      let(:params) { {} }

      before do
        subject.validate
      end

      it "returns an error if its empty" do
        expect(subject.errors[:nationality_names]).to include(
          I18n.t(
            "activemodel.errors.models.personal_details_form.attributes.nationality_names.empty_nationalities",
          ),
        )
      end

      context "when a blank autocomplete value is submitted" do
        let(:params) do
          ActionController::Parameters.new({
            "other" => "1",
            "other_nationality1" => "French",
            "other_nationality1_raw" => "",
            "nationality_names" => [""],
          }).permit!
        end

        it "returns an error " do
          expect(subject.errors[:nationality_names]).to include(
            I18n.t(
              "activemodel.errors.models.personal_details_form.attributes.nationality_names.empty_nationalities",
            ),
          )
        end
      end
    end

    context "date of birth" do
      context "invalid date" do
        let(:params) { { day: 323, month: 2, year: 1987 } }

        before do
          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:date_of_birth]).to include(
            I18n.t(
              "activemodel.errors.models.personal_details_form.attributes.date_of_birth.invalid",
            ),
          )
        end
      end

      context "invalid date year" do
        let(:params) { { day: 1, month: 4, year: 21 } }

        before do
          subject.validate
        end

        it "returns an invalid year error message" do
          expect(subject.errors[:date_of_birth]).to include(
            I18n.t("activemodel.errors.models.personal_details_form.attributes.date_of_birth.invalid_year"),
          )
        end
      end

      context "future date" do
        let(:params) { { day: 1, month: 2, year: 2021 } }

        before do
          subject.validate
        end

        around do |example|
          Timecop.freeze(Time.zone.local(2020, 1, 1)) do
            example.run
          end
        end

        it "is invalid" do
          expect(subject.errors[:date_of_birth]).to include(
            I18n.t(
              "activemodel.errors.models.personal_details_form.attributes.date_of_birth.future",
            ),
          )
        end
      end
    end
  end

  describe "#fields" do
    it "combines the data from params with the existing trainee data" do
      expect(subject.fields).to match({
        other_nationality1: "French",
        other_nationality1_raw: "French",
        other_nationality2: "American",
        other_nationality2_raw: "American",
        other_nationality3: "Irish",
        other_nationality3_raw: "Irish",
        first_names: "Millie",
        middle_names: "Schmeler",
        last_name: "Lehner",
        gender: "gender_not_provided",
        day: "11",
        month: "11",
        year: "1963",
        other: true,
        nationality_ids: [french.id, american.id, irish.id],
        nationality_names: [french.name.titleize, american.name.titleize, irish.name.titleize],
      })
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and personal_details" do
      expect(form_store).to receive(:set).with(trainee.id, :personal_details, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:params) { {} }

    before do
      allow(form_store).to receive(:get).and_return(fields)
    end

    it "takes any data from the form store and saves it to the database and clears the store data" do
      expect(form_store).to receive(:set).with(trainee.id, :personal_details, nil)

      expect { subject.save! }.to change(trainee, :first_names).to("Millie")
        .and change(trainee, :middle_names).to("Schmeler")
        .and change(trainee, :last_name).to("Lehner")
        .and change(trainee, :gender).to("gender_not_provided")
        .and change(trainee, :date_of_birth).to(Date.parse("11/11/1963"))
        .and change { trainee.nationalities.map(&:name).sort }.to(%w[american french irish])
    end
  end
end
