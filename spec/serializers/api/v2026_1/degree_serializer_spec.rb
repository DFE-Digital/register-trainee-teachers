# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::DegreeSerializer do
  let(:degree) { create(:degree) }
  let(:json) { described_class.new(degree).as_hash }

  describe "serialization" do
    let(:fields) do
      %w[
        degree_id
        uk_degree
        non_uk_degree
        created_at
        updated_at
        subject
        institution
        graduation_year
        grade
        country
        other_grade
        institution_uuid
        uk_degree_uuid
        subject_uuid
        grade_uuid
      ]
    end

    it "matches the fields" do
      expect(json.keys).to match_array(fields)
    end
  end
end
