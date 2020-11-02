require "rails_helper"

RSpec.describe Trainees::DegreesController, type: :controller do
  describe "#create" do
    let(:trainee) { create(:trainee) }
    let(:degree) { build(:degree, :uk_degree_with_details) }

    let(:degree_params) do
      {
        locale_code: degree.locale_code,
        uk_degree: degree.uk_degree,
        degree_subject: degree.degree_subject,
        institution: degree.institution,
        graduation_year: degree.graduation_year,
        degree_grade: degree.degree_grade,
      }
    end

    before do
      post(:create, params: { trainee_id: trainee.id, degree: degree_params })
    end

    it "creates a new degree record associated with the trainee" do
      expect(trainee.degrees.first).to have_attributes(degree_params)
    end

    it "redirects to trainee degree confirmation page" do
      expect(response).to redirect_to(trainee_degrees_confirm_path(trainee))
    end
  end
end
