# frozen_string_literal: true

require "rails_helper"

describe "vendor:create" do
  subject do
    Rake::Task["vendor:create"].execute
  end

  let(:generate_providers) {
    (1..10).to_a.reverse.map { |number|
      trainees = build_list(:trainee, number)
      create(:provider, trainees:)
    }
  }

  before do
    generate_providers
  end

  it "invoke vendor transform" do
    expect(Rake::Task["vendor:transform"]).to receive(:invoke).exactly(7).times
    expect(Rake::Task["vendor:transform"]).to receive(:reenable).exactly(7).times

    subject
  end
end
