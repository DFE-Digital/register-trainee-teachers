# frozen_string_literal: true

require "rails_helper"

describe TraineesController do
  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#show" do
    context "with a non-draft trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn, provider: user.provider) }

      before do
        get(:show, params: { id: trainee })
      end

      it "saves the origin page" do
        expect(session["origin_pages_for_#{trainee.id}"]).to eq(%w[trainee])
      end
    end

    context "with a draft trainee" do
      let(:trainee) { create(:trainee, :draft) }

      it "redirects to /review-draft" do
        expect(get(:show, params: { id: trainee })).to redirect_to(review_draft_trainee_path(trainee))
      end
    end
  end
end
