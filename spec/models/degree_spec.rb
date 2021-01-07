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
      end
    end

    describe "non-uk degree fields" do
      it "validates" do
        expect(subject).to validate_presence_of(:non_uk_degree).on(:non_uk)
        expect(subject).to validate_presence_of(:subject).on(:non_uk)
        expect(subject).to validate_presence_of(:country).on(:non_uk)
        expect(subject).to validate_presence_of(:graduation_year).on(:non_uk)
      end
    end

    describe "custom validations" do
      context "when graduation year is beyond the max limit" do
        let(:degree) { build(:degree, graduation_year: Time.zone.yesterday.year - Degree::MAX_GRAD_YEARS) }

        it "validates" do
          expect { degree.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(degree.errors.messages[:graduation_year]).to include(I18n.t(
                                                                        "activerecord.errors.models.degree.attributes.graduation_year.invalid",
                                                                      ))
        end
      end

      context "when graduation year is more than 1 year in the future" do
        let(:degree) { build(:degree, graduation_year: NEXT_YEAR + 1) }

        it "validates" do
          expect { degree.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(degree.errors.messages[:graduation_year]).to include(I18n.t(
                                                                        "activerecord.errors.models.degree.attributes.graduation_year.future",
                                                                      ))
        end
      end
    end
  end
end
