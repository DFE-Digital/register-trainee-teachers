# frozen_string_literal: true

require "rails_helper"
require "tempfile"

describe "schools_data:update_school_to_lead_school_publish" do
  let(:input_path) { input_file.path }
  let(:school_to_lead_school) {    create(:school) }
  let(:headers) { %w[urn name town postcode] }
  let(:csv_body) {
    <<~CSV
      #{headers.join(',')}
      #{school_to_lead_school.attributes.slice(*headers).values.join(',')}
    CSV
  }

  let(:input_file) do
    Tempfile.new(["fake_update_school_to_lead_school_publish", ".csv"]).tap do |f|
      f.write csv_body
      f.flush
      f.close
    end
  end

  before do
    allow($stdout).to receive(:puts)
  end

  subject do
    args = Rake::TaskArguments.new(
      %i[input_path],
      [input_path],
    )
    Rake::Task["schools_data:update_school_to_lead_school_publish"].execute(args)
  end

  it "updates the school to lead school" do
    expect { subject }.to change { school_to_lead_school.reload.lead_school }.from(false).to(true)
  end
end
