# frozen_string_literal: true

require "rails_helper"

describe AutocompleteValidator do
  class Validatable
    include ActiveModel::Validations
    attr_accessor :search, :search_raw

    validates :search, autocomplete: true
  end

  subject do
    Validatable.new.tap do |v|
      v.search = search
      v.search_raw = search_raw
    end
  end

  context "when the field/raw value are the same" do
    let(:search) { "Does ask jeeves still exist?" }
    let(:search_raw) { "Does ask jeeves still exist?" }

    it "does not add an error" do
      expect(subject).to be_valid
    end
  end

  context "when the field/raw value are different" do
    let(:search) { "Does ask jeeves still exist?" }
    let(:search_raw) { "Does jeeves" }

    it "adds an error" do
      expect(subject).not_to be_valid
      expect(subject.errors[:search]).not_to be_blank
    end

    # If the user hasn't selected something, we need to reset the value so that the autocomplete
    # doesn't clobber the raw value when the page reloads
    it "resets the field" do
      expect { subject.valid? }.to change { subject.search }
        .from("Does ask jeeves still exist?")
        .to("Does jeeves")
    end
  end
end
