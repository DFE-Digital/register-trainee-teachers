# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::Degrees::TypeController, type: :controller do
  describe "#create" do
    let(:user) { create(:user, provider: trainee.provider) }
    let(:trainee) { create(:trainee) }
    let(:response) do
      post(:create, params: { trainee_id: trainee,
                              degree:
      { locale_code: locale_code } })
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "uk" do
      let(:locale_code) { "uk" }

      it "redirects " do
        expect(response).to redirect_to(new_trainee_degree_path(trainee_id: trainee, locale_code: locale_code))
      end
    end

    context "non_uk" do
      let(:locale_code) { "non_uk" }

      it "redirects" do
        expect(response).to redirect_to(new_trainee_degree_path(trainee_id: trainee, locale_code: locale_code))
      end
    end
  end
end
