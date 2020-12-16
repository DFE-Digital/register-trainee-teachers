# frozen_string_literal: true

require "rails_helper"

describe PersonalDetailForm, type: :model do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_names) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_inclusion_of(:gender).in_array(Trainee.genders.keys) }

    context "nationalities" do
      before do
        subject.validate
      end

      it "returns an error if its empty" do
        expect(subject.errors[:nationality_ids]).to include(
          I18n.t(
            "activemodel.errors.models.personal_detail_form.attributes.nationality_ids.empty_nationalities",
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
              "activemodel.errors.models.personal_detail_form.attributes.date_of_birth.invalid",
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
              "activemodel.errors.models.personal_detail_form.attributes.date_of_birth.future",
            ),
          )
        end
      end
    end
  end
end
