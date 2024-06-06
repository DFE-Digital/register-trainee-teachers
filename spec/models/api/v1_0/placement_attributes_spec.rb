# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V10::PlacementAttributes do
  context "when school_id is blank" do
    before { subject.school_id = nil }

    it "validates presence of name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end
  end

  context "when urn is present" do
    it "validates format of urn" do
      subject.urn = "invalid_urn"
      expect(subject).not_to be_valid
      expect(subject.errors[:urn]).to include("is invalid")
    end
  end

  context "when subject, name, urn and postcode are missing" do
    before { subject.attributes = { name: nil, urn: nil, postcode: nil, school_id: nil } }

    it "adds an error on school_id" do
      expect(subject).not_to be_valid
      expect(subject.errors[:school_id]).to include("can't be blank")
    end
  end

  context "when postcode is present" do
    it "validates format of postcode" do
      subject.postcode = "invalid_postcode"
      expect(subject).not_to be_valid
      expect(subject.errors[:postcode]).to include(I18n.t("activemodel.errors.validators.postcode.invalid"))
    end

    it "is valid with a correct postcode" do
      subject.postcode = "SW1A 1AA"
      expect(subject.errors[:postcode]).not_to include(I18n.t("activemodel.errors.validators.postcode.invalid"))
    end
  end
end
