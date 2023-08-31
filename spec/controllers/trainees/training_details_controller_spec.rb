# frozen_string_literal: true

require "rails_helper"

describe Trainees::TrainingDetailsController do
  let(:user) { build_current_user }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#update" do
    context "with an apply draft trainee" do
      let(:trainee) { create(:trainee, :incomplete_draft, :with_apply_application, provider: user.organisation) }

      it "redirects to /training-details/confirm after update" do
        expect(put(:update, params: { trainee_id: trainee.slug, training_details_form: { trainee_id: "test" } })).to redirect_to("/trainees/#{trainee.slug}/training-details/confirm")
      end
    end
  end
end
