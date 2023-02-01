# frozen_string_literal: true

shared_examples "DeadJobs" do
  let(:service) { described_class.new(dead_set:, include_dqt_status:) }
  let(:include_dqt_status) { false }
  let(:trainee) { create(:trainee, :completed, :trn_received, sex: "female", hesa_id: 1) }
  let(:result) do
    {
      register_id: trainee.id,
      trainee_name: trainee.full_name,
      trainee_trn: trainee.trn,
      trainee_dob: trainee.date_of_birth,
      trainee_state: trainee.state,
      provider_name: trainee.provider.name,
      provider_ukprn: trainee.provider.ukprn,
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
          jid: "jobid1234",
        }.with_indifferent_access,
      ),
    ]
  end

  let(:csv) do
    <<~CSV
      register_id,trainee_name,trainee_trn,trainee_dob,trainee_state,provider_name,provider_ukprn,job_id,error_message
      #{trainee.id},#{trainee.full_name},#{trainee.trn},#{trainee.date_of_birth.strftime('%F')},#{trainee.state},#{trainee.provider.name},#{trainee.provider.ukprn},jobid1234,"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}"
    CSV
  end

  let(:csv_with_dqt_status) do
    <<~CSV
      register_id,trainee_name,trainee_trn,trainee_dob,trainee_state,provider_name,provider_ukprn,job_id,error_message,dqt_status
      #{trainee.id},#{trainee.full_name},#{trainee.trn},#{trainee.date_of_birth.strftime('%F')},#{trainee.state},#{trainee.provider.name},#{trainee.provider.ukprn},jobid1234,"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}",Pass
    CSV
  end

  let(:headers) { %i[register_id trainee_name trainee_trn trainee_dob trainee_state provider_name provider_ukprn] }

  describe "#to_csv" do
    context "excluding DQT status" do
      it "returns the expected CSV" do
        expect(service.to_csv).to eq(csv)
      end
    end

    context "including DQT status" do
      let(:include_dqt_status) { true }

      before do
        allow(Dqt::RetrieveTeacher).to receive(:call).with(trainee:).and_return(
          { "initial_teacher_training" => { "result" => "Pass" } },
        )
      end

      it "returns the expected CSV" do
        expect(service.to_csv(includes: %i[dqt_status])).to eq(csv_with_dqt_status)
      end
    end
  end

  describe "#headers" do
    it { expect(service.headers).to eq headers }
  end

  describe "#rows" do
    it "returns the expected array of hashes" do
      expect(service.rows).to eq([result])
    end
  end

  describe "#name" do
    it { expect(service.name).to eq name }
  end

  describe "#count" do
    it { expect(service.count).to eq 1 }
  end
end
