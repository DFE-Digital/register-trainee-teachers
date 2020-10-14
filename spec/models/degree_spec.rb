require "rails_helper"

RSpec.describe Degree, type: :model do
  describe "database fields" do
    it { is_expected.to have_db_column(:locale_code).with_options(uk: 0, non_uk: 1) }
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
  end
end
