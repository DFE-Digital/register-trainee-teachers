# frozen_string_literal: true

require "rails_helper"

describe "vendor:create" do
  subject do
    Rake::Task["vendor:create"].execute
  end

  let(:generate_providers) {
    (1..20).to_a.reverse.map { |number|
      trainees = build_list(:trainee, number)
      create(:provider, trainees:)
    }
  }

  before do
    generate_providers
  end

  it "invoke vendor swap" do
    expect(Rake::Task["vendor:swap"]).to receive(:invoke).exactly(17).times
    expect(Rake::Task["vendor:swap"]).to receive(:reenable).exactly(17).times

    subject
  end
end
