# frozen_string_literal: true

require "rails_helper"
require "tempfile"

describe "schools_data:generate_csv_from_publish" do
  let(:query_params) { "filter[provider_type]=lead_school&sort=name" }
  let(:output_path) do
    Tempfile.new(["fake", ".csv"]).path
  end
  let(:path) { "/recruitment_cycles/#{Settings.current_recruitment_cycle_year}/providers?#{query_params}" }
  let(:request_url) { "#{Settings.teacher_training_api.base_url}#{path}" }
  let(:http_response) { { status: 200, body: ApiStubs::TeacherTrainingApi.lead_schools.to_json } }

  before do
    allow($stdout).to receive(:puts)
    stub_request(:get, request_url).to_return(http_response)
  end

  subject do
    args = Rake::TaskArguments.new(
      %i[output_path],
      [output_path],
    )
    Rake::Task["schools_data:generate_csv_from_publish"].execute(args)
  end

  it "combines the relevant fields and outputs them to a csv" do
    subject

    row1 = CSV.read(output_path, headers: true).map(&:to_h).first
    expect(row1).to match_array(
      {
        "city" => "London",
        "name" => "Register Primary School",
        "postcode" => "N1 4PF",
        "urn" => "100000",
      },
    )
  end
end
