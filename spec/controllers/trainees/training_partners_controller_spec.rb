# frozen_string_literal: true

require "rails_helper"

describe Trainees::TrainingPartnersController do
  describe "#update" do
    let(:lead_partner) { create(:lead_partner, :school) }

    let(:params) do
      {
        lead_partner_id: lead_partner.id,
      }
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when school direct salaried trainee" do
      let(:trainee) { create(:trainee, :school_direct_salaried) }
      let(:user) { build_current_user(user: create(:user, providers: [trainee.provider])) }

      before do
        post(:update, params: { trainee_id: trainee, partners_lead_partner_form: params })
      end

      it "redirects to trainee employing school details page" do
        expect(response).to redirect_to(edit_trainee_employing_schools_details_path(trainee))
      end
    end

    context "when school direct tuition fee trainee" do
      let(:trainee) { create(:trainee, :school_direct_tuition_fee) }
      let(:user) { build_current_user(user: create(:user, providers: [trainee.provider])) }

      before do
        post(:update, params: { trainee_id: trainee, partners_lead_partner_form: params })
      end

      it "redirects to schools confirmation page" do
        expect(response).to redirect_to(trainee_schools_confirm_path(trainee))
      end
    end
  end
end
