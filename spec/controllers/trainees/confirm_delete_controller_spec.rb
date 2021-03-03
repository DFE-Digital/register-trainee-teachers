# frozen_string_literal: true

require "rails_helper"

describe Trainees::ConfirmDeleteController do
  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#show" do
    subject { get(:show, params: { trainee_id: trainee }) }

    context "with a non-draft trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn, provider: user.provider) }

      it "redirects to the trainee record page" do
        expect(subject).to redirect_to(trainee_path(trainee))
      end
    end
  end
end
