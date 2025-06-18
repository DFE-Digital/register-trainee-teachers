# frozen_string_literal: true

require "rails_helper"

describe Reports::ClaimsDegreeReport do
  describe "#generate_report" do
    def generate_csv_for_degrees(degrees_scope)
      CSV.generate do |csv|
        described_class.new(csv, scope: degrees_scope).generate_report
      end
    end

    context "with no degrees" do
      it "generates a CSV with correct headers and no data rows" do
        degrees = Degree.none
        csv_string = generate_csv_for_degrees(degrees)

        lines = csv_string.split("\n")
        expect(lines.first).to eq("trn,date_of_birth,nino,subject_code,description")
        expect(lines.count).to eq(1)
      end
    end

    context "with single-subject degree (has HECOS code)" do
      it "creates exactly one data row with HECOS code" do
        degree = create(:degree, :uk_degree_with_details,
                        subject_uuid: CodeSets::DegreeSubjects::MAPPING[DegreeSubjects::ACCOUNTANCY][:entity_id],
                        subject: "Accountancy")
        trainee = create(:trainee, :trn_received, degrees: [degree])

        csv_string = generate_csv_for_degrees(Degree.where(trainee:))

        expected_csv = <<~CSV
          trn,date_of_birth,nino,subject_code,description
          #{trainee.trn},#{trainee.date_of_birth.iso8601},,100104,Accountancy
        CSV

        expect(csv_string.strip).to eq(expected_csv.strip)
      end
    end

    context "with composite degree (no HECOS, has subject_ids)" do
      it "creates multiple rows - one for each constituent subject" do
        trainee = create(:trainee, :trn_received, :without_degrees, :with_hesa_trainee_detail,
                         training_route: "provider_led_postgrad")

        create(:degree, :uk_degree_with_details,
               trainee: trainee,
               subject_uuid: "469e7cc9-9691-45bd-859d-de8f9515913c", # Subject without HECOS code
               subject: "Accounting and finance")

        csv_string = generate_csv_for_degrees(Degree.where(trainee:))

        expected_csv = <<~CSV
          trn,date_of_birth,nino,subject_code,description
          #{trainee.trn},#{trainee.date_of_birth.iso8601},#{trainee.hesa_trainee_detail.ni_number},100105,Accounting
          #{trainee.trn},#{trainee.date_of_birth.iso8601},#{trainee.hesa_trainee_detail.ni_number},100107,Finance
        CSV

        expect(csv_string.strip).to eq(expected_csv.strip)
      end
    end

    context "with degree with no valid subject_uuid" do
      it "creates fallback row with empty HECOS code" do
        trainee = create(:trainee, :trn_received, :without_degrees, :with_hesa_trainee_detail,
                         training_route: "provider_led_postgrad")

        create(:degree, :uk_degree_with_details,
               trainee: trainee,
               subject_uuid: nil,
               subject: "Custom Subject")

        csv_string = generate_csv_for_degrees(Degree.where(trainee:))

        expected_csv = <<~CSV
          trn,date_of_birth,nino,subject_code,description
          #{trainee.trn},#{trainee.date_of_birth.iso8601},#{trainee.hesa_trainee_detail.ni_number},"",Custom Subject
        CSV

        expect(csv_string.strip).to eq(expected_csv.strip)
      end
    end
  end
end
