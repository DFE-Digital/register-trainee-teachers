# frozen_string_literal: true

require "rails_helper"

describe "example_data:generate" do
  subject { Rake::Task["example_data:generate"].execute }

  before do
    Nationality.create!(name: Dttp::CodeSets::Nationalities::MAPPING.keys.first)
  end

  it "creates two providers" do
    expect { subject }.to change(Provider, :count).by(2)
  end
end
