# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe FindTeacher do
    let(:trainee) { create(:trainee) }
    let(:dqt_trainee) {
      {
        "trn" => "0123456",
        "firstName" => trainee.first_names,
        "lastName" => trainee.last_name,
        "dateOfBirth" => trainee.date_of_birth,
      }
    }

    describe "#call" do
      before do
        enable_features(:integrate_with_dqt)
        allow(Dqt::Client).to receive(:get).and_return(dqt_response)
      end

      subject { described_class.call(trainee:) }

      context "when a teacher is found" do
        let(:dqt_response) { { "results" => [dqt_trainee] } }

        it "returns the teacher" do
          expect(subject).to eq(dqt_response["results"].first)
        end
      end

      context "when multiple teachers are found" do
        let(:dqt_response) { { "results" => [dqt_trainee, dqt_trainee] } }

        it "raises an error" do
          expect {
            subject
          }.to raise_error(
            FindTeacher::Error,
            "Multiple teachers found in DQT for trainee #{trainee.id}",
          )
        end
      end

      context "when no teacher is found" do
        let(:dqt_response) { { "results" => [] } }

        it "returns nil" do
          expect {
            subject
          }.to raise_error(
            FindTeacher::Error,
            "No teachers found in DQT for trainee #{trainee.id}",
          )
        end
      end

      context "when the trainee has multiple first names" do
        let(:trainee) { create(:trainee, first_names: "Bobby Joe") }

        let(:dqt_response) { { "results" => [dqt_trainee] } }

        it "calls the DQT API with just the _first_ first name" do
          described_class.call(trainee:)
          expected_params = {
            firstName: "Bobby",
            lastName: trainee.last_name,
            dateOfBirth: trainee.date_of_birth.iso8601,
            emailAddress: trainee.email,
          }
          expect(Client).to have_received(:get).with("/v2/teachers/find?#{expected_params.to_query}")
        end
      end
    end
  end
end
