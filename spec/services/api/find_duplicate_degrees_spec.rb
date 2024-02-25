# frozen_string_literal: true

require "rails_helper"

describe Api::FindDuplicateDegrees do
  let(:academic_cycle) { create(:academic_cycle, :current) }
  let(:trainee) do
    create(
      :trainee,
      itt_start_date: academic_cycle.start_date,
      first_names: "Bob",
      last_name: "Roberts",
      email: "bob@example.com",
    )
  end
  let!(:degree) { create(:degree, trainee: trainee, subject: "Biology") }
  let(:version) { "v0.1" }

  it "does not return degrees with a different subject" do
    degree_attributes = Api::DegreeAttributes.for(version).new(
      subject: "Physics",
    )

    expect(described_class.call(trainee:, degree_attributes:)).to be_empty
  end

  it "returns degrees that are an exact match" do
    degree_attributes = Api::DegreeAttributes.for(version).new(
      subject: "Biology",
    )

    expect(described_class.call(trainee:, degree_attributes:)).not_to be_empty
  end
end
