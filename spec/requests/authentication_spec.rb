require "rails_helper"

describe "authentication", type: :request do
  context "attempting to visit a restricted page" do
    context "without been authenticated" do
      it "redirects back to the persona page" do
        get trainees_path
        expect(response).to redirect_to(personas_path)
      end
    end

    context "already authenticated" do
      before do
        post sessions_path, params: { user_id: create(:user).id }
        get trainees_path
      end

      it "loads the restricted page" do
        expect(response).to have_http_status(200)
      end
    end
  end
end
