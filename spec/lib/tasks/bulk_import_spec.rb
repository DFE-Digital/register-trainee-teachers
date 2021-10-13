# frozen_string_literal: true

require "rails_helper"

describe "bulk_import:import" do
  include SeedHelper

  before do
    # Load Nationalities
    Dttp::CodeSets::Nationalities::MAPPING.each_key do |nationality|
      Nationality.find_or_create_by(name: nationality)
    end

    # Load Disabilities
    generate_seed_disabilities
  end

  subject do
    args = Rake::TaskArguments.new(%i[provider_code csv_path], [provider.code, csv_path])
    Rake::Task["bulk_import:import"].execute(args)
  end

  let!(:school) { create(:school, urn: 123, name: "Penwortham Primary School") }
  let!(:provider) { create(:provider) }
  let!(:course) { create(:course, provider: provider, code: "1CS", level: :secondary, study_mode: :full_time) }

  context "with valid data" do
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "bulk_import.csv")
    }

    it "creates the trainee/degree" do
      expect { subject }.to change { Trainee.count }.from(0).to(1)

      expect_trainee_to_have_attributes_from_csv(Trainee.first)
    end
  end

  context "with invalid data" do
    # This csv has two rows, the second row has an invalid degree subject that doesn't exist
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "bulk_import_invalid.csv")
    }

    it "gives an error including which row had the problem, and still creates the valid trainee" do
      expect(Sentry).to receive(:capture_exception).with(StandardError)
      expect { subject }.to change { Trainee.count }.from(0).to(1)
    end
  end

  context "with an existing trainee" do
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "bulk_import.csv")
    }

    it "raises an exception" do
      create(:trainee, provider: provider, trainee_id: "L0V3LYiD")
      expect { subject }.to raise_error(StandardError, "Duplicate trainee ids found in database")
    end
  end

  def expect_trainee_to_have_attributes_from_csv(trainee)
    expect(trainee.reload.course_age_range).to eq [7, 11]
    expect(trainee.course_start_date).to eq Date.parse("01/09/2021")
    expect(trainee.study_mode).to eq "full_time"
    expect(trainee.course_education_phase).to eq "secondary"

    expect(trainee.address_line_one).to eq "The mall"
    expect(trainee.postcode).to eq "SW1A 1AA"
    expect(trainee.town_city).to eq "London"

    expect(trainee.first_names).to eq "Jeff"
    expect(trainee.middle_names).to eq "McJeff"
    expect(trainee.last_name).to eq "Geoff"
    expect(trainee.date_of_birth).to eq Date.parse("13/04/1992")
    expect(trainee.email).to eq "jeff@example.com"
    expect(trainee.gender).to eq "female"

    expect(trainee.nationalities.count).to eq 1
    expect(trainee.nationalities.first).to eq Nationality.find_by_name("british")
    expect(trainee.diversity_disclosure).to eq Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
    expect(trainee.ethnic_background).to eq Diversities::NOT_PROVIDED
    expect(trainee.disabilities.map(&:name)).to contain_exactly("Learning difficulty")
    expect(trainee.disability_disclosure).to eq Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
    expect(trainee.employing_school).to eq school
    expect(trainee.provider).to eq provider

    expect(trainee.training_route).to eq "school_direct_salaried"
    expect(trainee.training_initiative).to eq "no_initiative"
    expect(trainee.trainee_id).to eq "L0V3LYiD"
    expect(trainee.commencement_date).to eq Date.parse("01/09/2021")

    expect(trainee.progress.attributes.values).to all eq(true)

    expect(trainee.degrees.count).to eq 1
    degree = trainee.degrees.first
    expect(degree.locale_code).to eq "uk"
    expect(degree.uk_degree).to eq "Bachelor of Arts"
    expect(degree.subject).to eq "International Hospitality Management"
  end
end
