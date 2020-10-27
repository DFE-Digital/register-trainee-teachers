require "rails_helper"

RSpec.describe Trainees::Degrees::TypeController, type: :controller do
  describe "#create" do
    let(:trainee) { create(:trainee) }
    let(:response) do
      post(:create, params: { trainee_id: trainee.id,
                              degree:
      { locale_code: locale_code } })
    end

    context "uk" do
      let(:locale_code) { "uk" }
      it "redirects " do
        expect(response).to redirect_to(new_trainee_degree_path(trainee_id: trainee.id, locale_code: locale_code))
      end
    end

    context "non_uk" do
      let(:locale_code) { "non_uk" }
      it "redirects" do
        expect(response).to redirect_to(new_trainee_degree_path(trainee_id: trainee.id, locale_code: locale_code))
      end
    end
  end
end
