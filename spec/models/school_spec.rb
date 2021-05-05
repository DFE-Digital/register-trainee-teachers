# frozen_string_literal: true

require "rails_helper"

describe School do
  context "callbacks" do
    it "updates the tsvector column with relevant info when the school is updated" do
      school = create(:school)
      expect {
        school.update(urn: "12345678", name: "School of life", postcode: "sw1a 1aa", town: "london")
      }.to change { school.reload.searchable }.to(
        "'12345678':1 '1aa':6 'life':4 'london':8 'of':3 'school':2 'sw1a':5 'sw1a1aa':7",
      )
    end
  end
end
