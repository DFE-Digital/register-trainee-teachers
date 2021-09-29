# frozen_string_literal: true

require "rails_helper"

describe "hpitt:import" do
  include SeedHelper

  before do
    # Load Nationalities
    Dttp::CodeSets::Nationalities::MAPPING.each_key do |nationality|
      Nationality.find_or_create_by(name: nationality)
    end

    # Load Disabilities
    generate_seed_diversities
  end

  subject do
    args = Rake::TaskArguments.new([:csv_path], [csv_path])
    Rake::Task["hpitt:import"].execute(args)
  end

  let!(:school) { create(:school, urn: 123) }
  let!(:provider) { create(:provider, :teach_first) }
  let!(:course) do
    create(
      :course,
      accredited_body_code: provider.code,
      duration_in_years: 1,
      start_date: Date.parse("13/04/2018"),
      name: "Toxicology",
      route: "school_direct_salaried",
    )
  end

  context "with valid data" do
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "hpitt_import.csv")
    }

    it "creates the trainee/degree" do
      expect { subject }.to change { Trainee.count }.from(0).to(1)

      expect_trainee_to_have_attributes_from_csv(Trainee.first)
    end
  end

  context "with invalid data" do
    # This csv has two rows, the second row has an invalid degree subject for a school that
    # doesn't exist
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "hpitt_import_invalid.csv")
    }

    it "gives an error including which row had the problem, and still creates the valid trainee" do
      expect(Sentry).to receive(:capture_exception).with(StandardError)
      expect { subject }.to change { Trainee.count }.from(0).to(1)
      # TODO: error csv
    end
  end

  context "with a preexisting trainee" do
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "hpitt_import.csv")
    }

    it "edits the existing trainee" do
      trainee = create(:trainee, :with_hpitt_provider, provider: provider, trainee_id: "L0V3LYiD")
      expect { subject }.not_to(change { Trainee.count })
      expect_trainee_to_have_attributes_from_csv(trainee)
    end
  end

  def expect_trainee_to_have_attributes_from_csv(trainee)
    expect(trainee.reload.course_age_range).to eq [0, 5]
    expect(trainee.course_start_date).to eq Date.parse("13/04/2018")

    expect(trainee.address_line_one).to eq "Buckingham Palace"
    expect(trainee.address_line_two).to eq "The mall"
    expect(trainee.postcode).to eq "SW1A 1AA"
    expect(trainee.town_city).to eq "Preston"

    expect(trainee.first_names).to eq "Jeff"
    expect(trainee.middle_names).to eq "Goeff"
    expect(trainee.last_name).to eq "McJeff"
    expect(trainee.date_of_birth).to eq Date.parse("13/04/1992")
    expect(trainee.email).to eq "jeff@example.com"
    expect(trainee.gender).to eq "female"

    expect(trainee.withdraw_date).to eq Date.parse("13/04/2020")
    expect(trainee.defer_date).to eq Date.parse("13/04/2021")

    expect(trainee.nationalities.count).to eq 1
    expect(trainee.nationalities.first).to eq Nationality.find_by_name("luxembourger")
    expect(trainee.disabilities.map(&:name)).to contain_exactly("Blind", "Deaf")
    expect(trainee.employing_school).to eq school
    expect(trainee.provider).to eq provider
    expect(trainee.region).to eq "West Midlands"

    expect(trainee.training_route).to eq "hpitt_postgrad"
    expect(trainee.trn).to eq "1234"
    expect(trainee.trainee_id).to eq "L0V3LYiD"

    expect(trainee.degrees.count).to eq 1
    degree = trainee.degrees.first
    expect(degree.locale_code).to eq "non_uk"
    expect(degree.non_uk_degree).to eq "Bachelor degree"
    expect(degree.subject).to eq "Toxicology"
    expect(degree.country).to eq "France"
  end
end
