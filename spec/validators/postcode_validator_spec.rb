# frozen_string_literal: true

require "rails_helper"

describe PostcodeValidator do
  let(:trainee) { build :trainee }
  subject { ContactDetailForm.new(trainee) }

  before do
    subject.postcode = postcode
  end

  context "with a valid UK postcode" do
    let(:postcode) { "SW1A 1AA" }

    it "does not add an error" do
      expect(subject).to be_valid
    end
  end

  context "with an invalid UK postcode" do
    let(:postcode) { "not really a postcode" }

    it "adds an error" do
      subject.postcode = "not really a postcode"
      expect(subject).not_to be_valid
      expect(subject.errors[:postcode]).not_to be_blank
    end
  end
end
