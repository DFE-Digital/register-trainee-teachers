# frozen_string_literal: true

require "rails_helper"

describe Exports::ExportTraineesToFileService, type: :model do
  include FileHelper

  describe "#call" do
    let(:filename) { Rails.root.join("tmp/export_trainees_test_data.csv") }
    let(:csv) { CSV.read(filename, headers: true) }
    let(:expected_headers) { Reports::TraineesReport.headers }
    let(:relevent_trainee_count) { Trainee.count }
    let(:trainee) { create(:trainee, :for_export) }
    let(:trainee_csv_row) { csv[0] }
    let(:trainees) { Trainee.all }

    subject(:service_call) { described_class.call(filename, trainees:) }

    before do
      trainee
      service_call
    end

    after do
      remove_file(filename)
    end

    it "inherits from ExportToFileServiceBase" do
      expect(described_class).to be < ExportToFileServiceBase
    end

    context "when given a filename" do
      it "creates a CSV file" do
        expect(File.exist?(filename)).to be true
      end

      it "includes a heading row and all relevant Trainees in the CSV file" do
        line_count = `wc -l "#{filename}"`.split.first.to_i
        expect(line_count).to eq(relevent_trainee_count + 1)
      end

      it "includes the correct headers" do
        expect(csv.headers).to match_array(expected_headers)
      end
    end

    context "when there are trainees" do
      let(:trainee_report) { Reports::TraineeReport.new(trainee) }

      it "includes the register_id in the csv" do
        expect(trainee_csv_row["register_id"]).to eq(trainee_report.register_id)
      end

      it "includes the trainee_url in the csv" do
        expect(trainee_csv_row["trainee_url"]).to end_with(trainee_report.trainee_url)
      end

      it "includes the record_source in the csv" do
        expect(trainee_csv_row["record_source"]).to eq(trainee_report.record_source)
      end

      it "includes the apply_id in the csv" do
        expect(trainee_csv_row["apply_id"]).to eq(trainee_report.apply_id)
      end

      it "includes the hesa_id in the csv" do
        expect(trainee_csv_row["hesa_id"]).to eq(trainee_report.hesa_id)
      end

      it "includes the provider_trainee_id in the csv" do
        expect(trainee_csv_row["provider_trainee_id"]).to eq(trainee_report.provider_trainee_id)
      end

      it "includes the trn in the csv" do
        expect(trainee_csv_row["trn"]).to eq(trainee_report.trn)
      end

      it "includes the trainee_status in the csv" do
        expect(trainee_csv_row["trainee_status"]).to eq(trainee_report.trainee_status)
      end

      it "includes the start_academic_year in the csv" do
        expect(trainee_csv_row["start_academic_year"]).to eq(trainee_report.start_academic_year)
      end

      it "includes the end_academic_year in the csv" do
        expect(trainee_csv_row["end_academic_year"]).to eq(trainee_report.end_academic_year)
      end

      it "includes the record_created_at in the csv" do
        expect(trainee_csv_row["record_created_at"]).to eq(trainee_report.record_created_at)
      end

      it "includes the register_record_last_changed_at in the csv" do
        expect(trainee_csv_row["register_record_last_changed_at"]).to eq(trainee_report.register_record_last_changed_at)
      end

      it "includes the hesa_record_last_changed_at in the csv" do
        expect(trainee_csv_row["hesa_record_last_changed_at"]).to eq(trainee_report.hesa_record_last_changed_at)
      end

      it "includes the submitted_for_trn_at in the csv" do
        expect(trainee_csv_row["submitted_for_trn_at"]).to eq(trainee_report.submitted_for_trn_at)
      end

      it "includes the provider_name in the csv" do
        expect(trainee_csv_row["provider_name"]).to eq(trainee_report.provider_name)
      end

      it "includes the provider_id in the csv" do
        expect(trainee_csv_row["provider_id"]).to eq(trainee_report.provider_id)
      end

      it "includes the first_names in the csv" do
        expect(trainee_csv_row["first_names"]).to eq(trainee_report.first_names)
      end

      it "includes the middle_names in the csv" do
        expect(trainee_csv_row["middle_names"]).to eq(trainee_report.middle_names)
      end

      it "includes the last_names in the csv" do
        expect(trainee_csv_row["last_names"]).to eq(trainee_report.last_names)
      end

      it "includes the date_of_birth in the csv" do
        expect(trainee_csv_row["date_of_birth"]).to eq(trainee_report.date_of_birth)
      end

      it "includes the sex in the csv" do
        expect(trainee_csv_row["sex"]).to eq(trainee_report.sex)
      end

      it "includes the nationality in the csv" do
        expect(trainee_csv_row["nationality"]).to eq(trainee_report.nationality)
      end

      it "does not include address_line_1 in the csv" do
        expect(trainee_csv_row["address_line_1"]).to be_nil
      end

      it "does not include address_line_2 in the csv" do
        expect(trainee_csv_row["address_line_2"]).to be_nil
      end

      it "does not include town_city in the csv" do
        expect(trainee_csv_row["town_city"]).to be_nil
      end

      it "does not include postcode in the csv" do
        expect(trainee_csv_row["postcode"]).to be_nil
      end

      it "does not include international_address in the csv" do
        expect(trainee_csv_row["international_address"]).to be_nil
      end

      it "includes the email_address in the csv" do
        expect(trainee_csv_row["email_address"]).to eq(trainee_report.email_address)
      end

      it "includes the diversity_disclosure in the csv" do
        expect(trainee_csv_row["diversity_disclosure"]).to eq(trainee_report.diversity_disclosure)
      end

      it "includes the ethnic_group in the csv" do
        expect(trainee_csv_row["ethnic_group"]).to eq(trainee_report.ethnic_group)
      end

      it "includes the ethnic_background in the csv" do
        expect(trainee_csv_row["ethnic_background"]).to eq(trainee_report.ethnic_background)
      end

      it "includes the ethnic_background_additional in the csv" do
        expect(trainee_csv_row["ethnic_background_additional"]).to eq(trainee_report.ethnic_background_additional)
      end

      it "includes the disability_disclosure in the csv" do
        expect(trainee_csv_row["disability_disclosure"]).to eq(trainee_report.disability_disclosure)
      end

      it "includes the disabilities in the csv" do
        expect(trainee_csv_row["disabilities"]).to eq(trainee_report.disabilities)
      end

      it "includes the number_of_degrees in the csv" do
        expect(trainee_csv_row["number_of_degrees"]).to eq(trainee_report.number_of_degrees.to_s)
      end

      it "includes the degree_1_uk_or_non_uk in the csv" do
        expect(trainee_csv_row["degree_1_uk_or_non_uk"]).to eq(trainee_report.degree_1_uk_or_non_uk)
      end

      it "includes the degree_1_awarding_institution in the csv" do
        expect(trainee_csv_row["degree_1_awarding_institution"]).to eq(trainee_report.degree_1_awarding_institution)
      end

      it "includes the degree_1_country in the csv" do
        expect(trainee_csv_row["degree_1_country"]).to eq(trainee_report.degree_1_country)
      end

      it "includes the degree_1_subject in the csv" do
        expect(trainee_csv_row["degree_1_subject"]).to eq(trainee_report.degree_1_subject)
      end

      it "includes the degree_1_type_uk in the csv" do
        expect(trainee_csv_row["degree_1_type_uk"]).to eq(trainee_report.degree_1_type_uk)
      end

      it "includes the degree_1_type_non_uk in the csv" do
        expect(trainee_csv_row["degree_1_type_non_uk"]).to eq(trainee_report.degree_1_type_non_uk)
      end

      it "includes the degree_1_grade in the csv" do
        expect(trainee_csv_row["degree_1_grade"]).to eq(trainee_report.degree_1_grade)
      end

      it "includes the degree_1_other_grade in the csv" do
        expect(trainee_csv_row["degree_1_other_grade"]).to eq(trainee_report.degree_1_other_grade)
      end

      it "includes the degree_1_graduation_year in the csv" do
        expect(trainee_csv_row["degree_1_graduation_year"]).to eq(trainee_report.degree_1_graduation_year.to_s)
      end

      it "includes the degrees in the csv" do
        expect(trainee_csv_row["degrees"]).to eq(trainee_report.degrees)
      end

      it "includes the course_training_route in the csv" do
        expect(trainee_csv_row["course_training_route"]).to eq(trainee_report.course_training_route)
      end

      it "includes the course_qualification in the csv" do
        expect(trainee_csv_row["course_qualification"]).to eq(trainee_report.course_qualification)
      end

      it "includes the course_education_phase in the csv" do
        expect(trainee_csv_row["course_education_phase"]).to eq(trainee_report.course_education_phase)
      end

      it "includes the course_subject_category in the csv" do
        expect(trainee_csv_row["course_subject_category"]).to eq(trainee_report.course_subject_category)
      end

      it "includes the course_itt_subject_1 in the csv" do
        expect(trainee_csv_row["course_itt_subject_1"]).to eq(trainee_report.course_itt_subject_1)
      end

      it "includes the course_itt_subject_2 in the csv" do
        expect(trainee_csv_row["course_itt_subject_2"]).to eq(trainee_report.course_itt_subject_2)
      end

      it "includes the course_itt_subject_3 in the csv" do
        expect(trainee_csv_row["course_itt_subject_3"]).to eq(trainee_report.course_itt_subject_3)
      end

      it "includes the course_minimum_age in the csv" do
        expect(trainee_csv_row["course_minimum_age"]).to eq(trainee_report.course_minimum_age.to_s)
      end

      it "includes the course_maximum_age in the csv" do
        expect(trainee_csv_row["course_maximum_age"]).to eq(trainee_report.course_maximum_age.to_s)
      end

      it "includes the course_full_or_part_time in the csv" do
        expect(trainee_csv_row["course_full_or_part_time"]).to eq(trainee_report.course_full_or_part_time)
      end

      it "includes the course_level in the csv" do
        expect(trainee_csv_row["course_level"]).to eq(trainee_report.course_level)
      end

      it "includes the itt_start_date in the csv" do
        expect(trainee_csv_row["itt_start_date"]).to eq(trainee_report.itt_start_date)
      end

      it "includes the expected_end_date in the csv" do
        expect(trainee_csv_row["expected_end_date"]).to eq(trainee_report.expected_end_date)
      end

      it "includes the course_duration_in_years in the csv" do
        expect(trainee_csv_row["course_duration_in_years"]).to eq(trainee_report.course_duration_in_years.to_s)
      end

      it "includes the trainee_start_date in the csv" do
        expect(trainee_csv_row["trainee_start_date"]).to eq(trainee_report.trainee_start_date)
      end

      it "includes the training_partner_name in the csv" do
        expect(trainee_csv_row["training_partner_name"]).to eq(trainee_report.training_partner_name)
      end

      it "includes the training_partner_urn in the csv" do
        expect(trainee_csv_row["training_partner_urn"]).to eq(trainee_report.training_partner_urn)
      end

      it "includes the employing_school_name in the csv" do
        expect(trainee_csv_row["employing_school_name"]).to eq(trainee_report.employing_school_name)
      end

      it "includes the employing_school_urn in the csv" do
        expect(trainee_csv_row["employing_school_urn"]).to eq(trainee_report.employing_school_urn)
      end

      it "includes the training_initiative in the csv" do
        expect(trainee_csv_row["training_initiative"]).to eq(trainee_report.training_initiative)
      end

      it "includes the funding_method in the csv" do
        expect(trainee_csv_row["funding_method"]).to eq(trainee_report.funding_method)
      end

      it "includes the funding_value in the csv" do
        expect(trainee_csv_row["funding_value"]).to eq(trainee_report.funding_value.to_s)
      end

      it "includes the bursary_tier in the csv" do
        expect(trainee_csv_row["bursary_tier"]).to eq(trainee_report.bursary_tier)
      end

      it "includes the award_standards_met_date in the csv" do
        expect(trainee_csv_row["award_standards_met_date"]).to eq(trainee_report.award_standards_met_date)
      end

      it "includes the award_given_at in the csv" do
        expect(trainee_csv_row["award_given_at"]).to eq(trainee_report.award_given_at)
      end

      it "includes the defer_date in the csv" do
        expect(trainee_csv_row["defer_date"]).to eq(trainee_report.defer_date)
      end

      it "includes the return_from_deferral_date in the csv" do
        expect(trainee_csv_row["return_from_deferral_date"]).to eq(trainee_report.return_from_deferral_date)
      end

      it "includes the withdraw_date in the csv" do
        expect(trainee_csv_row["withdraw_date"]).to eq(trainee_report.withdraw_date)
      end

      it "includes the withdraw_reasons in the csv" do
        expect(trainee_csv_row["withdraw_reasons"]).to eq(trainee_report.withdraw_reasons)
      end

      it "includes the withdrawal_trigger in the csv" do
        expect(trainee_csv_row["withdrawal_trigger"]).to eq(trainee_report.withdrawal_trigger)
      end

      it "includes the withdrawal_future_interest in the csv" do
        expect(trainee_csv_row["withdrawal_future_interest"]).to eq(trainee_report.withdrawal_future_interest)
      end
    end
  end
end
