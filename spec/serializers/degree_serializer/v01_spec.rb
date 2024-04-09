# frozen_string_literal: true

require "rails_helper"

RSpec.describe DegreeSerializer::V01 do
  let(:degree) { create(:degree) }
  let(:json) { described_class.new(degree).as_hash.with_indifferent_access }

  describe "serialization" do
    it "includes all expected fields" do
      %w[
        degree_id
        uk_degree
        non_uk_degree
        graduation_year
        subject
        grade
        institution
        country
        other_grade
      ].each do |field|
        expect(json.keys).to include(field)
      end
    end

    it "does not include excluded fields" do
      %w[
        id
        slug
        dttp_id
      ].each do |field|
        expect(json.keys).not_to include(field)
      end
    end
  end
end
