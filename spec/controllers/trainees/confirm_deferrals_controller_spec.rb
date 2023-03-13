# frozen_string_literal: true

require "rails_helper"

describe Trainees::ConfirmDeferralsController do
  include ActiveJob::TestHelper

  let(:current_user) { build_current_user }
  let(:trainee) { create(:trainee, :trn_received, provider: current_user.organisation) }
  let(:deferral_form) { double(save!: true) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(DeferralForm).to receive(:new).with(trainee).and_return(deferral_form)
  end

  describe "#update" do
    before do
      post :update, params: { trainee_id: trainee }
    end

    it "transitions the trainee state to deferred" do
      expect(deferral_form).to have_received(:save!)
    end
  end
end
