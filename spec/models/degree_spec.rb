# frozen_string_literal: true

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
      it "expect it to be valid" do
        expect(subject).to validate_presence_of(:locale_code)
      end
    end

    describe "uk degree fields" do
      it "validates" do
        expect(subject).to validate_presence_of(:uk_degree).on(:uk)
        expect(subject).to validate_presence_of(:subject).on(:uk)
        expect(subject).to validate_presence_of(:institution).on(:uk)
        expect(subject).to validate_presence_of(:grade).on(:uk)
        expect(subject).to validate_presence_of(:graduation_year).on(:uk)
        expect(subject).to validate_inclusion_of(:graduation_year)
          .in_range(1900..Time.zone.today.year).on(:uk)
      end
    end

    describe "non-uk degree fields" do
      it "validates" do
        expect(subject).to validate_presence_of(:non_uk_degree).on(:non_uk)
        expect(subject).to validate_presence_of(:subject).on(:non_uk)
        expect(subject).to validate_presence_of(:country).on(:non_uk)
        expect(subject).to validate_presence_of(:graduation_year).on(:non_uk)
        expect(subject).to validate_inclusion_of(:graduation_year)
          .in_range(1900..Time.zone.today.year).on(:non_uk)
      end
    end
  end
end
