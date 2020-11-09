require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  let(:user) { create(:user, provider: create(:provider)) }

  context "active persona" do
    before do
      controller.request.session = { auth_user: { user_id: user.id } }
    end

    describe "#current_user" do
      it "fetches the user record from the auth_user session" do
        expect(controller.send(:current_user)).to eq(user)
      end
    end

    describe "#authenticated?" do
      it "fetches the user record from the auth_user session" do
        expect(controller.send(:authenticated?)).to eq(true)
      end
    end
  end
end
