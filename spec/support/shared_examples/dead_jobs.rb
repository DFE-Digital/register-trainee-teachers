# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "Dead jobs" do |dead_jobs_klass, name|
  let(:job_id) { SecureRandom.hex }
  let(:trainee) { create(:trainee, :completed, :trn_received, sex: "female", hesa_id: 1) }
  let(:csv) { CSV.parse(subject.to_csv, headers: true) }

  let(:dead_set) do
    [
      OpenStruct.new(
        item: {
          wrapped: dead_jobs_klass.to_s,
          args: [
            {
              arguments: [
                { _aj_globalid: "gid://register-trainee-teachers/Trainee/#{trainee.id}" },
              ],
            },
          ],
          error_message: 'status: 400, body: {"title":"Teacher has no incomplete ITT record","status":400,"errorCode":10005}, headers: ',
          jid: job_id,
        }.with_indifferent_access,
      ),
    ]
  end

  let(:dqt_response) do
    { "trn" => "1234567",
      "firstName" => "Bobby",
      "lastName" => "Burger",
      "middleName" => "Chrystal",
      "dateOfBirth" => "1989-11-01",
      "hasActiveSanctions" => false,
      "initialTeacherTraining" =>
      [{ "programmeStartDate" => "2022-09-03",
         "programmeEndDate" => "2023-07-01",
         "programmeType" => "InternationalQualifiedTeacherStatus",
         "result" => "InTraining",
         "provider" => { "ukprn" => "10007159" },
         "husId" => nil,
         "active" => true }] }
  end

  let(:dqt_response_humanised) do
    <<~TEXT
      trn: 1234567
      firstName: Bobby
      lastName: Burger
      middleName: Chrystal
      dateOfBirth: 1989-11-01
      hasActiveSanctions: false
      initialTeacherTraining: [{"programmeStartDate"=>"2022-09-03", "programmeEndDate"=>"2023-07-01", "programmeType"=>"InternationalQualifiedTeacherStatus", "result"=>"InTraining", "provider"=>{"ukprn"=>"10007159"}, "husId"=>nil, "active"=>true}]
    TEXT
  end

  before do
    allow(Dqt::RetrieveTeacher).to receive(:call).with(trainee:).and_return(dqt_response)
  end

  subject { described_class.new(dead_set: dead_set, include_dqt_status: true) }

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
      expect(csv[0]["error_message"]).to eql "{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}"
      expect(csv[0]["dqt"]).to eql dqt_response_humanised
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
