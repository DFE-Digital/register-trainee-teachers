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
          #{headers.join(',')},job_id,error_message,params_sent
          #{row},#{job_id},"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}","#{params_sent}"
        CSV
      end

      let(:csv_with_dqt_status) do
        <<~CSV
          #{headers.join(',')},job_id,error_message,params_sent,dqt_status
          #{row},#{job_id},"{'title'=>'Teacher has no incomplete ITT record', 'status'=>400, 'errorCode'=>10005}","#{params_sent}",Pass
        CSV
      end
    end
  end
end
