# frozen_string_literal: true

shared_examples "DeadJobs" do
  let(:service) { described_class.new(dead_set:, include_dqt_status:) }
  let(:include_dqt_status) { false }
  let(:trainee) { create(:trainee, :completed, :trn_received, sex: "female", hesa_id: 1) }
  let(:dqt_trn_params) { Dqt::Params::TrnRequest.new(trainee:).params }
  let(:programme_route) { dqt_trn_params.dig("initialTeacherTraining", "programmeType") }
  let(:programme_start_date) { dqt_trn_params.dig("initialTeacherTraining", "programmeStartDate") }
  let(:programme_end_date) { dqt_trn_params.dig("initialTeacherTraining", "programmeEndDate") }
  let(:job_id) { "jobid1234" }

  let(:result) do
    {
      register_id: trainee.id,
      trainee_name: trainee.full_name,
      trainee_trn: trainee.trn,
      trainee_dob: trainee.date_of_birth,
      trainee_state: trainee.state,
      provider_name: trainee.provider.name,
      provider_ukprn: trainee.provider.ukprn,
      programme_route: programme_route,
      programme_start_date: programme_start_date,
      programme_end_date: programme_end_date,
    }
  end

  let(:dead_set) do
    [
      OpenStruct.new(
        item: {
          wrapped: klass,
          args:
            [
              {
                arguments: [
                  { _aj_globalid: "gid://register-trainee-teachers/Trainee/#{trainee.id}" },
                  { _aj_serialized: "ActiveJob::Serializers::TimeWithZoneSerializer", value: "2023-01-15T00:00:42.798653522Z" },
                ],
              },
            ],
          error_message: 'status: 400, body: {"title":"Teacher has no incomplete ITT record","status":400,"errorCode":10005}, headers: ',
          jid: job_id,
        }.with_indifferent_access,
      ),
    ]
  end

  let(:headers) { DeadJobs::Base::DEFAULT_HEADERS }
  let(:row) { result.dup.merge(trainee_dob: result[:trainee_dob].strftime("%F")).values.join(",") }

  let(:csv) do
    <<~CSV
      #{headers.join(',')},job_id,error_message
      #{row},#{job_id},"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}"
    CSV
  end

  let(:csv_with_dqt_status) do
    <<~CSV
      #{headers.join(',')},job_id,error_message,dqt_status
      #{row},#{job_id},"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}",Pass
    CSV
  end

  describe "#to_csv" do
    context "excluding DQT status" do
      it "returns the expected CSV" do
        expect(service.to_csv).to eq(csv)
      end
    end

    context "including DQT status" do
      let(:include_dqt_status) { true }

      before do
        allow(Dqt::RetrieveTraining).to receive(:call).with(trainee:).and_return(
          { "result" => "Pass" },
        )
      end

      it "returns the expected CSV" do
        expect(service.to_csv(includes: %i[dqt_status])).to eq(csv_with_dqt_status)
      end
    end
  end

  describe "#headers" do
    it { expect(service.headers).to eq(headers) }
  end

  describe "#rows" do
    it "returns the expected array of hashes" do
      expect(service.rows).to eq([result])
    end
  end

  describe "#name" do
    it { expect(service.name).to eq(name) }
  end

  describe "#count" do
    it { expect(service.count).to eq(1) }
  end
end
