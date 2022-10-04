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

      subject { described_class.call(trainee: trainee) }

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
            Dqt::FindTeacher::Error,
            "Multiple teachers found with firstName: #{trainee.first_names}, lastName: #{trainee.last_name}, dateOfBirth: #{trainee.date_of_birth}",
          )
        end
      end

      context "when no teacher is found" do
        let(:dqt_response) { { "results" => [] } }

        it "returns nil" do
          expect {
            subject
          }.to raise_error(
            Dqt::FindTeacher::Error,
            "No teachers found with firstName: #{trainee.first_names}, lastName: #{trainee.last_name}, dateOfBirth: #{trainee.date_of_birth}",
          )
        end
      end
    end
  end
end
