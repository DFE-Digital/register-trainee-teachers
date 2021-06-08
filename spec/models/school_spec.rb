# frozen_string_literal: true

require "rails_helper"

describe School do
  context "callbacks" do
    it "updates the tsvector column with relevant info when the school is updated" do
      school = create(:school)
      expect {
        school.update(urn: "12345678", name: "St Leo's and Southmead", postcode: "sw1a 1aa", town: "london")
      }.to change { school.reload.searchable }.to(
        "'12345678':1 '1aa':12 'and':5,9 'leo':3 'leos':8 'london':14 's':4 'southmead':6,10 'st':2,7 'sw1a':11 'sw1a1aa':13",
      )
    end
  end
end
