# frozen_string_literal: true

require "rails_helper"

describe PersonalDetailsForm, type: :model do
  let(:trainee) { create(:trainee) }
  let(:form_store) { class_double(FormStore) }

  let(:params) do
    {
      "first_names" => "Millie",
      "middle_names" => "Schmeler",
      "last_name" => "Lehner",
      "gender" => "gender_not_provided",
      "day" => "11",
      "month" => "11",
      "year" => "1963",
      "other" => "1",
      "other_nationality1" => "170",
      "other_nationality2" => "1",
      "other_nationality3" => "",
      "nationality_ids" => ["", "100"],
    }
  end

  subject { described_class.new(trainee, params, form_store) }

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
        expect(subject.errors[:nationality_ids]).to include(
          I18n.t(
            "activemodel.errors.models.personal_details_form.attributes.nationality_ids.empty_nationalities",
          ),
        )
      end
    end

    context "date of birth" do
      subject { described_class.new(trainee, attributes) }

      context "invalid date" do
        let(:attributes) { { day: 323, month: 2, year: 1987 } }

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

      context "future date" do
        let(:attributes) { { day: 1, month: 2, year: 2021 } }

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
        other_nationality1: "170",
        other_nationality2: "1",
        other_nationality3: "",
        first_names: "Millie",
        middle_names: "Schmeler",
        last_name: "Lehner",
        gender: "gender_not_provided",
        day: "11",
        month: "11",
        year: "1963",
        other: true,
        nationality_ids: [100, 170, 1],
      })
    end
  end

  describe "#save_to_store" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and personal_details" do
      expect(form_store).to receive(:set).with(trainee.id, :personal_details, subject.fields)

      subject.save_to_store
    end
  end

  describe "#save!" do
    let(:params) { {} }
    let(:nationality) { create(:nationality) }
    let(:first_names) { Faker::Name.first_name }

    before do
      allow(form_store).to receive(:get).and_return({ "first_names" => first_names, nationality_ids: [nationality.id] })
    end

    it "takes any data from the form store and saves it to the database and clears the store data" do
      expect(form_store).to receive(:set).with(trainee.id, :personal_details, nil)

      expect { subject.save! }.to change(trainee, :first_names).to(first_names)
    end
  end
end
