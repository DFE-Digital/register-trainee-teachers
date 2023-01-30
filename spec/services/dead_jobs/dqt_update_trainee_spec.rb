# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtUpdateTrainee do
    it_behaves_like "DeadJobs" do
      let(:klass) { "Dqt::UpdateTraineeJob" }
      let(:name) { "Dqt update trainee" }

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
