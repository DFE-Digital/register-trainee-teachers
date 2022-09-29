# frozen_string_literal: true

require "rails_helper"

describe "trainees:create_from_csv" do
  include SeedHelper

  subject do
    args = Rake::TaskArguments.new(%i[provider_code csv_path], [provider.code, csv_path])
    Rake::Task["trainees:create_from_csv"].execute(args)
  end

  before do
    generate_seed_nationalities
    generate_seed_disabilities
    create(:subject_specialism, name: CourseSubjects::HISTORY)
    create(:subject_specialism, name: CourseSubjects::FRENCH_LANGUAGE)
    create(:subject_specialism, name: CourseSubjects::SPANISH_LANGUAGE)
    create(:subject_specialism, name: CourseSubjects::ITALIAN_LANGUAGE)
  end

  context "with valid data" do
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "hpitt_import.csv")
    }
    let!(:provider) { create(:provider, :teach_first) }

    before { subject }

    it "sets the trainee's personal details" do
      trainee = Trainee.first
      expect(trainee.reload.trainee_id).to eq("A1")
      expect(trainee.first_names).to eq("Abz")
      expect(trainee.middle_names).to be_nil
      expect(trainee.last_name).to eq("McPhee")
      expect(trainee.date_of_birth).to eq(Date.parse("1990-04-23"))
      expect(trainee.email).to eq("test@example.com")
      expect(trainee.sex).to eq("female")
    end

    it "sets the trainee's address" do
      trainee = Trainee.first
      expect(trainee.address_line_one).to eq("1 This Road")
      expect(trainee.address_line_two).to be_nil
      expect(trainee.town_city).to eq("London")
      expect(trainee.postcode).to eq("SW1A 1AA")
      expect(trainee.region).to eq("South West")
    end

    it "sets the trainee's diversity details" do
      trainee = Trainee.first
      expect(trainee.nationalities.count).to eq(1)
      expect(trainee.nationalities.first).to eq(Nationality.find_by_name("british"))
      expect(trainee.diversity_disclosure).to eq Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
      expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:asian])
      expect(trainee.ethnic_background).to eq(Diversities::INDIAN)
      expect(trainee.disability_disclosure).to eq Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
      expect(trainee.disabilities.count).to eq(0)
    end

    it "sets the trainee's course details" do
      trainee = Trainee.first
      expect(trainee.itt_start_date).to eq(Date.parse("9/9/2022"))
      expect(trainee.itt_end_date).to eq(Date.parse("31/7/2023"))
      expect(trainee.trainee_start_date).to eq(Date.parse("9/9/2022"))
      expect(trainee.course_subject_one).to eq("history")
      expect(trainee.study_mode).to eq("full_time")
      expect(trainee.course_education_phase).to eq("secondary")
      expect(trainee.training_route).to eq("hpitt_postgrad")
      expect(trainee.training_initiative).to eq("no_initiative")
    end

    it "sets the trainee's degree details" do
      degree = Trainee.first.degrees.first
      expect(degree.locale_code).to eq("non_uk")
      expect(degree.non_uk_degree).to eq("Bachelor degree")
      expect(degree.subject).to eq("English studies")
      expect(degree.country).to eq("Germany")
    end
  end

  context "with invalid HPITT data" do
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "hpitt_import_invalid.csv")
    }
    let!(:provider) { create(:provider, :teach_first) }

    it "gives an error for the invalid row, and still creates the valid trainee" do
      expect(Sentry).to receive(:capture_exception).with(StandardError)
      expect { subject }.to change { Trainee.count }.from(0).to(1)
    end
  end

  context "with valid SCITT data" do
    let(:csv_path) {
      File.join(__dir__, "..", "..", "support", "fixtures", "bulk_import.csv")
    }
    let!(:provider) { create(:provider) }

    before { subject }

    it "sets the trainee's personal details" do
      trainee = Trainee.first
      expect(trainee.reload.trainee_id).to eq("TF2022-123")
      expect(trainee.first_names).to eq("Fred")
      expect(trainee.middle_names).to eq("Rock")
      expect(trainee.last_name).to eq("Flintstone")
      expect(trainee.date_of_birth).to eq(Date.parse("1970-01-29"))
      expect(trainee.email).to eq("fred.flintstone@example.com")
      expect(trainee.sex).to eq("male")
    end

    it "sets the trainee's address details" do
      trainee = Trainee.first
      expect(trainee.address_line_one).to eq("10 Fiddlesticks lane")
      expect(trainee.address_line_two).to eq("Ambleside")
      expect(trainee.town_city).to eq("Frome")
      expect(trainee.postcode).to eq("SW1A 2AA")
    end

    it "sets the trainee's diversity details" do
      trainee = Trainee.first
      expect(trainee.nationalities.count).to eq(2)
      expect(trainee.nationalities).to include(Nationality.find_by_name("british"))
      expect(trainee.nationalities).to include(Nationality.find_by_name("french"))
      expect(trainee.diversity_disclosure).to eq Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
      expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:asian])
      expect(trainee.ethnic_background).to eq(Diversities::BANGLADESHI)
      expect(trainee.disability_disclosure).to eq Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
      expect(trainee.disabilities.count).to eq(2)
      expect(trainee.region).to be_nil
    end

    it "sets the trainee's course details" do
      trainee = Trainee.first
      expect(trainee.itt_start_date).to eq(Date.parse("28/9/2022"))
      expect(trainee.itt_end_date).to eq(Date.parse("25/7/2023"))
      expect(trainee.trainee_start_date).to eq(Date.parse("28/9/2022"))
      expect(trainee.course_subject_one).to eq("French language")
      expect(trainee.course_subject_two).to eq("Spanish language")
      expect(trainee.course_subject_three).to eq("Italian language")
      expect(trainee.study_mode).to eq("full_time")
      expect(trainee.course_education_phase).to eq("secondary")
      expect(trainee.training_route).to eq("school_direct_salaried")
      expect(trainee.training_initiative).to eq("no_initiative")
    end

    it "sets the trainee's degree details" do
      degree = Trainee.first.degrees.first
      expect(degree.locale_code).to eq("uk")
      expect(degree.uk_degree).to eq("Bachelor of Arts")
      expect(degree.grade).to eq("First-class honours")
      expect(degree.graduation_year).to eq(2016)
      expect(degree.non_uk_degree).to be_nil
      expect(degree.subject).to eq("English studies")
      expect(degree.country).to be_nil
    end
  end
end
