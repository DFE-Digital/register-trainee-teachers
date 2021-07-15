# frozen_string_literal: true

require "rails_helper"

describe Trainees::PersonalDetailsController do
  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#show" do
    context "with a non-draft trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn, provider: user.provider) }

      before do
        get(:show, params: { trainee_id: trainee })
      end

      it "saves the origin page" do
        expect(session["origin_pages_for_#{trainee.slug}"]).to eq(["/trainees/#{trainee.slug}/personal-details"])
      end
    end

    context "with a draft trainee" do
      let(:trainee) { create(:trainee, :draft, provider: user.provider) }

      it "redirects to /review-draft" do
        expect(get(:show, params: { trainee_id: trainee })).to redirect_to(review_draft_trainee_path(trainee))
      end
    end
  end

  describe "#update" do
    context "with an apply draft trainee" do
      let(:trainee) { create(:trainee, :draft, :with_apply_application, provider: user.provider) }

      before do
        allow(PersonalDetailsForm).to receive(:new).and_return(double(save!: true))
        allow(controller).to receive(:page_tracker).and_return(double(last_origin_page_path: "/trainees/#{trainee.slug}/relevant-redirect", save!: nil))
        allow(controller).to receive(:personal_details_params).and_return(nil)
      end

      it "redirects to /relevant-redirect after update" do
        expect(put(:update, params: { trainee_id: trainee.slug })).to redirect_to("/trainees/#{trainee.slug}/relevant-redirect")
      end
    end
  end
end
