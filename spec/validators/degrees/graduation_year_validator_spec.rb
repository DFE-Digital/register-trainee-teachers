# frozen_string_literal: true

require "rails_helper"

RSpec.describe Degrees::GraduationYearValidator do
  subject { described_class.new(attributes: [:graduation_year]) }

  let(:record) do
    Class.new do
      include ActiveModel::Validations

      def self.name
        "TestClass"
      end

      attr_accessor :graduation_year

      def next_year = 1.year.from_now.year
    end.new
  end

  before do
    subject.validate_each(record, :graduation_year, graduation_year)
  end

  context "when graduation_year is nil" do
    let(:graduation_year) { nil }

    it "is valid" do
      expect(record).to be_valid
    end
  end

  context "when graduation_year is empty" do
    let(:graduation_year) { "" }

    it "is valid" do
      expect(record).to be_valid
    end
  end

  context "when graduation_year is present" do
    context "with graduation_year > next_year" do
      let(:graduation_year) { 2.years.from_now.year }

      it "is invalid" do
        expect(record.errors[:graduation_year]).to contain_exactly("is invalid", "must be in the future")
      end
    end

    context "with graduation_year between (next_year - MAX_GRAD_YEARS) and next_year" do
      let(:graduation_year) { 1900 }

      it "is invalid" do
        expect(record.errors[:graduation_year]).to contain_exactly("is invalid")
      end
    end
  end
end
