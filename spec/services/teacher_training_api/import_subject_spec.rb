# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe ImportSubject do
    describe "#call" do
      let(:api_subject) { ApiStubs::TeacherTrainingApi.subject }
      let(:code) { api_subject[:attributes][:code] }
      let(:name) { api_subject[:attributes][:name] }

      subject { described_class.call(subject: api_subject) }

      context "when the subject code does not exist in register" do
        it "create a subject with the correct code and name" do
          subject
          expect(Subject.find_by(code: code, name: name)).to_not be_nil
        end
      end

      context "when the subject code already exists" do
        context "with the same name" do
          before { create(:subject, code: code, name: name) }

          it "does not create a duplicate subject" do
            expect { subject }.not_to(change { Subject.count })
          end
        end

        context "with a different name" do
          before { create(:subject, code: code) }

          it "updates the name" do
            subject
            expect(Subject.find_by(code: code).name).to eq name
          end
        end
      end
    end
  end
end
