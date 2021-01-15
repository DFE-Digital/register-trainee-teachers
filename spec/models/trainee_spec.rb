# frozen_string_literal: true

require "rails_helper"

describe Trainee do
  context "fields" do
    subject { build(:trainee) }

    it { is_expected.to define_enum_for(:record_type).with_values(assessment_only: 0, provider_led: 1) }
    it { is_expected.to define_enum_for(:locale_code).with_values(uk: 0, non_uk: 1) }
    it { is_expected.to define_enum_for(:gender).with_values(male: 0, female: 1, other: 2, gender_not_provided: 3) }

    it do
      is_expected.to define_enum_for(:diversity_disclosure).with_values(
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] => 0,
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] => 1,
      )
    end

    it do
      is_expected.to define_enum_for(:disability_disclosure).with_values(
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] => 0,
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] => 1,
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] => 2,
      )
    end

    it do
      is_expected.to define_enum_for(:ethnic_group).with_values(
        Diversities::ETHNIC_GROUP_ENUMS[:asian] => 0,
        Diversities::ETHNIC_GROUP_ENUMS[:black] => 1,
        Diversities::ETHNIC_GROUP_ENUMS[:mixed] => 2,
        Diversities::ETHNIC_GROUP_ENUMS[:white] => 3,
        Diversities::ETHNIC_GROUP_ENUMS[:other] => 4,
        Diversities::ETHNIC_GROUP_ENUMS[:not_provided] => 5,
      )
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_many(:degrees).dependent(:destroy) }
    it { is_expected.to have_many(:nationalisations).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:nationalities).through(:nationalisations) }
    it { is_expected.to have_many(:trainee_disabilities).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:disabilities).through(:trainee_disabilities) }
  end

  context "class methods" do
    describe ".dttp_id" do
      let(:uuid) { "2795182a-43b2-4543-bf83-ad95fbfce7fd" }

      context "when passed as an attribute" do
        it "uses the attribute" do
          trainee = create(:trainee, dttp_id: uuid)
          expect(trainee.dttp_id).to eq(uuid)
        end
      end

      context "when it has already been set" do
        it "raises an exception" do
          trainee = create(:trainee, dttp_id: uuid)

          expect { trainee.dttp_id = uuid }.to raise_error(LockedAttributeError)
        end
      end

      describe "validation" do
        context "when record type is present" do
          subject { build(:trainee, record_type: "assessment_only") }

          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "when record type is not present" do
          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors.attribute_names).to include(:record_type)
          end
        end

        context "when trainee id is over 100 characters" do
          subject { build(:trainee, trainee_id: SecureRandom.alphanumeric(101)) }

          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors.attribute_names).to include(:trainee_id)
          end
        end

        context "when trainee id is under 100 characters" do
          subject { build(:trainee, trainee_id: SecureRandom.alphanumeric(99)) }

          it "is valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end

  describe "#with_name_trainee_id_or_trn_like" do
    let(:other_trainee) { create(:trainee) }
    let(:matching_trainee) do
      create(:trainee, middle_names: "Firstmiddle Secondmiddle", trn: "123")
    end

    subject { described_class.with_name_trainee_id_or_trn_like(search_term) }

    shared_examples_for "a working search" do
      it "returns the matching trainee" do
        expect(subject).to contain_exactly(matching_trainee)
      end
    end

    context "with an exactly matching first name" do
      let(:search_term) { matching_trainee.first_names }
      it_behaves_like "a working search"
    end

    context "with exactly matching (second) middle name" do
      let(:search_term) { "Secondmiddle" }
      it_behaves_like "a working search"
    end

    context "with exactly matching last name" do
      let(:search_term) { matching_trainee.last_name }
      it_behaves_like "a working search"
    end

    context "with a matching trainee id" do
      let(:search_term) { matching_trainee.trn }
      it_behaves_like "a working search"
    end

    context "with extra spaces in the search term" do
      let(:search_term) { "Firstmiddle  Secondmiddle" }
      it_behaves_like "a working search"
    end

    context "with incorrect case" do
      let(:search_term) { "firstMiddle" }
      it_behaves_like "a working search"
    end

    context "with partial search term" do
      let(:search_term) { "First" }
      it_behaves_like "a working search"
    end
  end

  describe "#ordered_by_date" do
    let(:trainee_one) { create(:trainee, updated_at: 1.day.ago) }
    let(:trainee_two) { create(:trainee, updated_at: 1.hour.ago) }

    it "orders the trainess by updated_at in descending order" do
      expect(Trainee.ordered_by_date).to eq([trainee_two, trainee_one])
    end
  end

  describe "auditing" do
    it { should be_audited.associated_with(:provider) }
  end
end
