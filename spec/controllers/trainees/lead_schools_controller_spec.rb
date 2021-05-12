# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::LeadSchoolsController, type: :controller do
  describe "#update" do
    let(:lead_school) { create(:school, :lead) }

    let(:params) do
      {
        lead_school_id: lead_school.id,
      }
    end

    context "when school direct salaried trainee" do
      let(:trainee) { create(:trainee, :school_direct_salaried) }
      let(:user) { create(:user, provider: trainee.provider) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        post(:update, params: { trainee_id: trainee, schools_lead_school_form: params })
      end

      it "redirects to trainee employing school page" do
        expect(response).to redirect_to(edit_trainee_employing_schools_path(trainee))
      end
    end

    context "when school direct tuition fee trainee" do
      let(:trainee) { create(:trainee, :school_direct_tuition_fee) }
      let(:user) { create(:user, provider: trainee.provider) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        post(:update, params: { trainee_id: trainee, schools_lead_school_form: params })
      end

      it "redirects to schools confirmation page" do
        expect(response).to redirect_to(trainee_schools_confirm_path(trainee))
      end
    end
  end
end
