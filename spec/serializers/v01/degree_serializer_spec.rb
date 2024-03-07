require "rails_helper"

RSpec.describe DegreeSerializer::V01 do
  let(:degree) { create(:degree) }
  let(:json) { described_class.new(degree).as_hash.with_indifferent_access }

  DEGREE_FIELDS = %i[
    uk_degree
    non_uk_degree
    graduation_year
    subject
    grade
    institution
    country
    other_grade
  ].freeze

  describe "serialization" do
    DEGREE_FIELDS.each do |field|
      it "serializes the #{field} field from the specification" do
        expect(json).to have_key(field)
      end
    end
  end
end
