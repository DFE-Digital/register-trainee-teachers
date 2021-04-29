# frozen_string_literal: true

require "rails_helper"

module Exports
  describe TraineeSearchData do
    let(:trainee) do
      create(:trainee, :with_course_details, :submitted_for_trn, :trn_received, :recommended_for_award, :awarded)
    end

    subject { described_class.new([trainee]) }

    describe "#data" do
      let(:expected_output) do
        {
          "First name" => trainee.first_names,
          "Last name" => trainee.last_name,
          "Trainee Id" => trainee.trainee_id,
          "TRN" => trainee.trn,
          "Status" => t("exports.trainees.award_given", award_type: trainee.award_type),
          "Route" => trainee.training_route,
          "Subject" => trainee.subject,
          "Course start date" => trainee.course_start_date,
          "Course end date" => trainee.course_end_date,
          "Created date" => trainee.created_at,
          "Last updated date" => trainee.updated_at,
          "TRN Submitted date" => trainee.submitted_for_trn_at,
          "Award submitted date" => trainee.recommended_for_award_at,
        }
      end

      it "sets the correct headers" do
        expect(subject.data).to include(expected_output.keys.join(","))
      end

      it "sets the correct row values" do
        expect(subject.data).to include(expected_output.values.join(","))
      end
    end

    describe "#time" do
      let(:time_now_in_zone) { Time.zone.now }

      let(:expected_filename) do
        "#{time_now_in_zone.strftime('%Y-%m-%d_%H-%M_%S')}_Register-trainee-teachers_exported_records.csv"
      end

      before do
        allow(Time).to receive(:now).and_return(time_now_in_zone)
      end

      it "sets the correct filename" do
        expect(subject.filename).to eq(expected_filename)
      end
    end
  end
end
