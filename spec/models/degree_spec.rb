require "rails_helper"

RSpec.describe Degree, type: :model do
  describe "database fields" do
    it { is_expected.to define_enum_for(:locale_code).with_values(uk: 0, non_uk: 1) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:trainee) }
  end

  describe "validation" do
    context "when locale code is present" do
      it "is present" do
        expect(subject).to validate_presence_of(:locale_code)
      end
    end

    context "uk degree is present" do
      subject { described_class.new(locale_code: :uk) }

      it "validates" do
        expect(subject).to validate_presence_of(:uk_degree)
      end
    end

    context "uk degree is not present" do
      subject { described_class.new(locale_code: :non_uk) }

      it "does not validate" do
        expect(subject).to_not validate_presence_of(:uk_degree)
      end
    end

    context "non-uk degree is present" do
      subject { described_class.new(locale_code: :non_uk) }

      it "validates" do
        expect(subject).to validate_presence_of(:non_uk_degree)
      end
    end

    context "non-uk degree is not present" do
      subject { described_class.new(locale_code: :uk) }

      it "does not validate" do
        expect(subject).to_not validate_presence_of(:non_uk_degree)
      end
    end

    describe "uk degree fields" do
      it "validates" do
        expect(subject).to validate_presence_of(:degree_subject).on(:uk)
        expect(subject).to validate_presence_of(:institution).on(:uk)
        expect(subject).to validate_presence_of(:degree_grade).on(:uk)
        expect(subject).to validate_presence_of(:graduation_year).on(:uk)
        expect(subject).to validate_inclusion_of(:graduation_year)
          .in_range(1900..Time.zone.today.year).on(:uk)
      end
    end
  end
end
