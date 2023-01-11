# frozen_string_literal: true

shared_examples "DeadJobs" do |klass, name|
  let(:service) { described_class.new(dead_set) }
  let(:trainee) { create(:trainee, :trn_received) }
  let(:result) do
    {
      register_id: trainee.id,
      trainee_name: trainee.full_name,
      trainee_trn: trainee.trn,
      trainee_dob: trainee.date_of_birth,
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
        }.with_indifferent_access,
      ),
    ]
  end

  describe "#to_a" do
    it "returns the expected array of hashes" do
      expect(service.to_a).to eq(
        [
          { **result, error_message: { "title" => "Teacher has no incomplete ITT record", "status" => 400, "errorCode" => 10005 } },
        ],
      )
    end
  end

  describe "#to_csv" do
    it do
      expect(service.to_csv).to eq(
        <<~CSV # rubocop:disable Style/TrailingCommaInArguments
          register_id,trainee_name,trainee_trn,trainee_dob,provider_name,provider_ukprn,error_message
          #{trainee.id},#{trainee.full_name},#{trainee.trn},#{trainee.date_of_birth.strftime('%F')},#{trainee.provider.name},#{trainee.provider.ukprn},"{""title""=>""Teacher has no incomplete ITT record"", ""status""=>400, ""errorCode""=>10005}"
        CSV
      )
    end
  end

  describe "#headers" do
    it { expect(service.headers).to eq %i[register_id trainee_name trainee_trn trainee_dob provider_name provider_ukprn] }
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
