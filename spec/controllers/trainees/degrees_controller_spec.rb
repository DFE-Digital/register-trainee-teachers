require "rails_helper"

RSpec.describe Trainees::DegreesController, type: :controller do
  describe "#create" do
    let(:trainee) { create(:trainee) }
    let(:post_method) do
      post(:create, params: { trainee_id: trainee.id,
                              degree:
      { locale_code: :uk,
        uk_degree: "Bachelor of Arts",
        degree_subject: "History",
        institution: "The University of Warwick",
        graduation_year: 2014,
        degree_grade: "Upper second-class honours (2:1)" } })
    end

    it "saves the degree of the trainee to db" do
      expect { post_method }.to change { trainee.reload.degrees.size }.from(0).to(1)
    end
  end
end
