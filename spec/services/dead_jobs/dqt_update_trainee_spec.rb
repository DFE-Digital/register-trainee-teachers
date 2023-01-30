# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtUpdateTrainee do
    it_behaves_like "DeadJobs" do
      let(:klass) { "Dqt::UpdateTraineeJob" }
      let(:name) { "Dqt update trainee" }

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

      let(:params_sent) { Dqt::Params::TraineeRequest.new(trainee:).to_json.to_s.gsub('"', "'") }

      let(:csv) do
        <<~CSV
          register_id,trainee_name,trainee_trn,trainee_dob,trainee_state,provider_name,provider_ukprn,error_message,job_id,params_sent
          #{trainee.id},#{trainee.full_name},#{trainee.trn},#{trainee.date_of_birth.strftime('%F')},#{trainee.state},#{trainee.provider.name},#{trainee.provider.ukprn},"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}",jobid1234,"#{params_sent}"
        CSV
      end
    end
  end
end
