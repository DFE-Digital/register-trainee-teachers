# frozen_string_literal: true

require "rails_helper"

describe Degree do
  describe "database fields" do
    it { is_expected.to define_enum_for(:locale_code).with_values(uk: 0, non_uk: 1) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:trainee) }
  end

  describe "default scope" do
    it { expect(Degree.all.to_sql).to eq(Degree.all.order(graduation_year: :asc).to_sql) }
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
          expect(degree.errors.messages[:graduation_year]).to contain_exactly(
            "Enter a valid graduation year",
          )
        end
      end

      context "when graduation year is more than 1 year in the future" do
        let(:degree) { build(:degree, graduation_year: Time.zone.now.year.next + 1) }

        it "validates" do
          expect { degree.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(degree.errors.messages[:graduation_year]).to contain_exactly(
            "Enter a graduation year that is in the past, for example 2014",
            "Enter a valid graduation year",
          )
        end
      end
    end

    context "slug" do
      subject { create(:degree) }

      let(:degree_with_matching_slug) { create(:degree, slug: subject.slug.downcase) }

      it "ensures unique case insensitive slugs" do
        expect { degree_with_matching_slug } .to raise_error(ActiveRecord::RecordNotUnique)
      end

      context "immutability" do
        let(:original_slug) { subject.slug.dup }

        before do
          original_slug
          subject.regenerate_slug
          subject.reload
        end

        it "is immutable once created" do
          expect(subject.slug).to eq(original_slug)
        end
      end
    end
  end

  describe "#apply_import?" do
    let(:degree) { create(:degree) }

    subject { degree.apply_import? }

    it { is_expected.to be_falsey }

    context "when is_apply_import is set to true" do
      let(:degree) { create(:degree, is_apply_import: "true") }

      it { is_expected.to be_truthy }
    end
  end
end
