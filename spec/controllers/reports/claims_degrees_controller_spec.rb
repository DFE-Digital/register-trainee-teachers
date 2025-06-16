# frozen_string_literal: true

require "rails_helper"

module Reports
  describe ClaimsDegreesController do
    let(:provider) { create(:provider) }

    context "when user is a system admin" do
      let(:user) { build_current_user(user: create(:user, :system_admin, providers: [provider])) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      describe "#index" do
        context "when no form data is submitted" do
          it "renders the index template" do
            get :index
            expect(response).to render_template(:index)
          end

          it "assigns a form object" do
            get :index
            expect(assigns(:form)).to be_a(ClaimsDegreesForm)
          end
        end

        context "when valid form data is submitted" do
          before do
            trainee = create(:trainee, :trn_received)
            create(:degree, trainee: trainee, created_at: Date.new(2023, 6, 15))
          end

          it "returns a CSV file with correct headers" do
            get :index, params: {
              reports_claims_degrees_form: {
                "from_date(1i)" => "2023",
                "from_date(2i)" => "1",
                "from_date(3i)" => "1",
                "to_date(1i)" => "2023",
                "to_date(2i)" => "12",
                "to_date(3i)" => "31",
              },
            }

            expect(response).to have_http_status(:ok)
            expect(response.headers["Content-Type"]).to include("text/csv")
            expect(response.headers["Content-Disposition"]).to include("attachment")
          end
        end

        context "when form validation fails" do
          it "renders the index template with errors" do
            get :index, params: {
              reports_claims_degrees_form: {
                "from_date(1i)" => "2030",
                "from_date(2i)" => "1",
                "from_date(3i)" => "1",
              },
            }

            expect(response).to render_template(:index)
            expect(response.content_type).to include("text/html")
            expect(assigns(:form).errors).to be_present
          end
        end
      end
    end

    context "when user is not a system admin" do
      let(:user) { build_current_user(user: create(:user, providers: [provider])) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      describe "#index" do
        it "redirects to root path" do
          get :index
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
