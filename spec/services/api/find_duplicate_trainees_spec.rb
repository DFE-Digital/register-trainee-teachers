# frozen_string_literal: true

require "rails_helper"

describe Api::FindDuplicateTrainees do
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
  let(:version) { "v0.1" }

  it "does not return trainees for a different provider" do
    attributes = Api::TraineeAttributes.for(version).new(
      first_names: "Bob",
      last_name: "Roberts",
      date_of_birth: trainee.date_of_birth,
      training_route: trainee.training_route,
      itt_start_date: trainee.itt_start_date,
    )

    expect(described_class.call(current_provider: create(:provider), trainee_attributes: attributes)).to be_empty
  end

  it "does not return trainees with a different date of birth" do
    attributes = Api::TraineeAttributes.for(version).new(
      first_names: "Bob",
      last_name: "Roberts",
      date_of_birth: trainee.date_of_birth + 1.day,
      training_route: trainee.training_route,
      itt_start_date: trainee.itt_start_date,
    )

    expect(described_class.call(current_provider: trainee.provider, trainee_attributes: attributes)).to be_empty
  end

  it "does not return trainees with a different last name" do
    attributes = Api::TraineeAttributes.for(version).new(
      first_names: "Bob",
      last_name: "Jones",
      date_of_birth: trainee.date_of_birth,
      training_route: trainee.training_route,
      itt_start_date: trainee.itt_start_date,
    )

    expect(described_class.call(current_provider: trainee.provider, trainee_attributes: attributes)).to be_empty
  end

  it "returns trainees that are an exact match" do
    attributes = Api::TraineeAttributes.for(version).new(
      first_names: "Bob",
      last_name: "Roberts",
      date_of_birth: trainee.date_of_birth,
      training_route: trainee.training_route,
      itt_start_date: trainee.itt_start_date,
    )

    expect(described_class.call(current_provider: trainee.provider, trainee_attributes: attributes)).not_to be_empty
  end

  it "returns trainees that are an inexact match (different email)" do
    attributes = Api::TraineeAttributes.for(version).new(
      first_names: "Bob",
      last_name: "Roberts",
      date_of_birth: trainee.date_of_birth,
      training_route: trainee.training_route,
      itt_start_date: trainee.itt_start_date,
      email: "rob@example.com",
    )

    expect(described_class.call(current_provider: trainee.provider, trainee_attributes: attributes)).not_to be_empty
  end

  it "returns trainees that are an inexact match (different first name)" do
    attributes = Api::TraineeAttributes.for(version).new(
      first_names: "Bobbie",
      last_name: "Roberts",
      date_of_birth: trainee.date_of_birth,
      training_route: trainee.training_route,
      itt_start_date: trainee.itt_start_date,
      email: trainee.email,
    )

    expect(described_class.call(current_provider: trainee.provider, trainee_attributes: attributes)).not_to be_empty
  end

  it "doesn't return trainees that are have a different first name and email" do
    attributes = Api::TraineeAttributes.for(version).new(
      first_names: "Bobbie",
      last_name: "Roberts",
      date_of_birth: trainee.date_of_birth,
      training_route: trainee.training_route,
      itt_start_date: trainee.itt_start_date,
      email: "robbie@example.com",
    )

    expect(described_class.call(current_provider: trainee.provider, trainee_attributes: attributes)).to be_empty
  end
end
