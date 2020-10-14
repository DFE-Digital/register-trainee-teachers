require "rails_helper"

RSpec.describe Trainees::DegreesController, type: :controller do
  describe "#create" do
    let(:trainee) { create(:trainee) }
    let(:post_method) { post :create, params: { trainee_id: trainee.id, degree: { locale_code: :uk, uk_degree: "Bachelor of Arts" } } }

    it "saves the degree of the trainee to db" do
      expect { post_method }.to change { trainee.reload.degrees.size }.from(0).to(1)
    end
  end
end
