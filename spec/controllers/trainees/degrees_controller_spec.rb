# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::DegreesController, type: :controller do
  describe "#create" do
    let(:user) { create(:user, provider: trainee.provider) }
    let(:trainee) { create(:trainee) }
    let(:degree) { build(:degree, :uk_degree_with_details) }

    let(:degree_params) do
      {
        locale_code: degree.locale_code,
        uk_degree: degree.uk_degree,
        subject: degree.subject,
        institution: degree.institution,
        graduation_year: degree.graduation_year,
        grade: degree.grade,
      }
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
      post(:create, params: { trainee_id: trainee, degree: degree_params })
    end

    it "creates a new degree record associated with the trainee" do
      expect(trainee.degrees.first).to have_attributes(degree_params)
    end

    it "redirects to trainee degree confirmation page" do
      expect(response).to redirect_to(trainee_degrees_confirm_path(trainee))
    end
  end
end
