require "rails_helper"

module Trainees
  RSpec.describe PreviousEducationController do
    describe "#edit" do
      let(:trainee) { build(:trainee) }
      let(:id) { "1" }

      before do
        expect(Trainee).to receive(:find).with(id).and_return(trainee)
        get :edit, params: { id: id }
      end

      it "returns 200" do
        expect(response).to be_successful
      end
    end
  end
end
