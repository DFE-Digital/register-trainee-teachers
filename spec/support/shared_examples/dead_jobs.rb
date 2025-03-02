# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "Dead jobs" do |dead_jobs_klass, name|
  let(:job_id) { SecureRandom.hex }
  let(:trainee) { create(:trainee, :completed, :trn_received, sex: "female", hesa_id: 1) }
  let!(:dqt_teacher) { create(:dqt_teacher, :with_teacher_training, trn: trainee.trn) }
  let(:dqt_teacher_training) { dqt_teacher.dqt_trainings.first }
  let(:csv) { CSV.parse(subject.to_csv, headers: true) }

  let(:dead_set) do
    [
      OpenStruct.new(
        item: {
          wrapped: dead_jobs_klass.to_s,
          args: [
            {
              arguments: [
                { trainee_id: { _aj_globalid: "gid://register-trainee-teachers/Trainee/#{trainee.id}" } },
              ],
            },
          ],
          error_message: 'status: 400, body: {"title":"Teacher has no incomplete ITT record","status":400,"errorCode":10005}, headers: ',
          jid: job_id,
        }.with_indifferent_access,
      ),
    ]
  end

  subject { described_class.new(dead_set:) }

  describe "#to_csv" do
    it "returns CSV content" do
      expect(csv.headers).to include(
        *%w[
          register_id
          job_id
          url
          trn
          date_of_birth
          full_name
          email
          state
          provider_name
          provider_ukprn
          training_route
          itt_start_date
          itt_end_date
          course_min_age
          course_max_age
          course_subject_one
          course_subject_two
          course_subject_three
          error_message
          dqt
        ],
      )

      expect(csv[0]["register_id"]).to eql trainee.id.to_s
      expect(csv[0]["job_id"]).to eql job_id.to_s
      error_message = csv[0]["error_message"]
      expect(error_message).to include("title")
      expect(error_message).to include("Teacher has no incomplete ITT record")
      expect(error_message).to include("status")
      expect(error_message).to include("400")
      expect(error_message).to include("errorCode")
      expect(error_message).to include("10005")
    end

    context "with dqt status" do
      subject { described_class.new(dead_set: dead_set, include_dqt_status: true) }

      context "with dqt teacher" do
        let(:dqt_response_humanised) do
          training = dqt_teacher.dqt_trainings.first
          <<~TEXT
            trn: #{dqt_teacher.trn}
            first_name: #{dqt_teacher.first_name}
            last_name: #{dqt_teacher.last_name}
            date_of_birth: #{dqt_teacher.date_of_birth}
            dqt_teacher_trainings:
          TEXT
        end

        it "returns the dqt status" do
          dqt_data = csv[0]["dqt"]
          expect(dqt_data).to include("trn: #{dqt_teacher.trn}")
          expect(dqt_data).to include("first_name: #{dqt_teacher.first_name}")
          expect(dqt_data).to include("last_name: #{dqt_teacher.last_name}")
          expect(dqt_data).to include("date_of_birth: #{dqt_teacher.date_of_birth}")
          expect(dqt_data).to include("programme_start_date")
          expect(dqt_data).to include("programme_end_date")
          expect(dqt_data).to include("programme_type")
          expect(dqt_data).to include("result")
          expect(dqt_data).to include("provider_ukprn")
          expect(dqt_data).to include("hesa_id")
          expect(dqt_data).to include("active")
        end
      end

      context "without dqt teacher" do
        let(:dqt_teacher) { nil }

        it "returns nil" do
          expect(csv[0]["dqt"]).to be_nil
        end
      end
    end
  end

  describe "#headers" do
    it "returns an array of header names" do
      expect(subject.headers).to include(
        *%i[
          register_id
          trn
          name
          date_of_birth
          state
          job_id
          days_waiting
        ],
      )
    end
  end

  describe "#rows" do
    it "returns an array of row data" do
      expect(subject.rows.first[:register_id]).to eq(trainee.id)
    end
  end

  describe "#name" do
    it "returns the human-friendly name of the job" do
      expect(subject.name).to eq(name)
    end
  end
end
