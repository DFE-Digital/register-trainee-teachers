# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtUpdateTrainee do
    it_behaves_like "DeadJobs" do
      let(:klass) { "Dqt::UpdateTraineeJob" }
      let(:name) { "DQT Update Trainee" }

      let(:params_sent) { Dqt::Params::TraineeRequest.new(trainee:).to_json.to_s.gsub('"', "'") }

      let(:csv) do
        <<~CSV
          register_id,trainee_name,trainee_trn,trainee_dob,trainee_state,provider_name,provider_ukprn,job_id,error_message,params_sent
          #{trainee.id},#{trainee.full_name},#{trainee.trn},#{trainee.date_of_birth.strftime('%F')},#{trainee.state},#{trainee.provider.name},#{trainee.provider.ukprn},jobid1234,"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}","#{params_sent}"
        CSV
      end

      let(:csv_with_dqt_status) do
        <<~CSV
          register_id,trainee_name,trainee_trn,trainee_dob,trainee_state,provider_name,provider_ukprn,job_id,error_message,params_sent,dqt_status
          #{trainee.id},#{trainee.full_name},#{trainee.trn},#{trainee.date_of_birth.strftime('%F')},#{trainee.state},#{trainee.provider.name},#{trainee.provider.ukprn},jobid1234,"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}","#{params_sent}",Pass
        CSV
      end
    end
  end
end
