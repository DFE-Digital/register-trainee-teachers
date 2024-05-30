# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V01::DegreeSerializer do
  let(:degree) { create(:degree) }
  let(:json) { described_class.new(degree).as_hash.with_indifferent_access }

  describe "serialization" do
    it "includes all expected fields" do
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
      ].each do |field|
        expect(json.keys).to include(field)
      end
    end

    it "does not include excluded fields" do
      %w[
        id
        trainee_id
        slug
        dttp_id
        locale_code
      ].each do |field|
        expect(json.keys).not_to include(field)
      end
    end
  end
end
