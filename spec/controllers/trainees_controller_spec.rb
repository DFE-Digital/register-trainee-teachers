# frozen_string_literal: true

require "rails_helper"

describe TraineesController do
  let(:trainee) { create(:trainee) }
  let(:user) { build(:user) }
  let(:trainee_policy) { instance_double(TraineePolicy, show?: true) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(TraineePolicy).to receive(:new).with(user, trainee).and_return(trainee_policy)
  end

  describe "#show" do
    before { get(:show, params: { id: trainee }) }

    it "saves the origin page" do
      expect(session["origin_pages_for_#{trainee.id}"]).to eq(%w[trainee])
    end
  end
end
