# frozen_string_literal: true

require "rails_helper"

module TraineeAdmin
  describe View, type: :component do
    let(:trainee) { build(:trainee, trn: "1234567") }
    let(:user) { build(:user) }
    let(:trs_response) { { "trn" => "1234567", "firstName" => "John", "lastName" => "Doe" } }

    subject { described_class.new(trainee: trainee, current_user: user) }

    describe "#trs_data", feature_integrate_with_trs: true do
      before do
        allow(Trs::RetrieveTeacher).to receive(:call).with(trainee:).and_return(trs_response)
      end

      it "calls the TRS service" do
        expect(Trs::RetrieveTeacher).to receive(:call).with(trainee:)
        subject.trs_data
      end

      it "returns the response from the TRS service" do
        expect(subject.trs_data).to eq(trs_response)
      end

      context "when the TRS service raises an HttpError" do
        before do
          allow(Trs::RetrieveTeacher).to receive(:call).with(trainee:).and_raise(Trs::Client::HttpError)
        end

        it "returns false" do
          expect(subject.trs_data).to be(false)
        end
      end
    end

    describe "#trs_data", feature_integrate_with_trs: false do
      it "does not call the TRS service" do
        expect(Trs::RetrieveTeacher).not_to receive(:call)
        subject.trs_data
      end

      it "returns nil" do
        expect(subject.trs_data).to be_nil
      end
    end

    describe "rendering", feature_integrate_with_trs: true do
      before do
        allow(Trs::RetrieveTeacher).to receive(:call).with(trainee:).and_return(trs_response)

        render_inline(described_class.new(trainee: trainee, current_user: user))
      end

      it "renders the component" do
        expect(rendered_content).to be_present
      end
    end
  end
end
