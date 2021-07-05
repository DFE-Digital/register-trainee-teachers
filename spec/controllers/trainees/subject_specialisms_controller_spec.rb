# frozen_string_literal: true

require "rails_helper"

describe Trainees::SubjectSpecialismsController do
  let(:user) { create(:user) }
  let(:trainee) { create(:trainee, :submitted_for_trn, provider: user.provider) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#update" do
    context "there are more specialisms to choose" do
      let!(:course) { create(:course_with_subjects, subjects_count: 2) }

      it "does nice things" do
        put(:update, params: { trainee_id: trainee, position: 1, subject_specialism_form: { specialism1: "moose" } })
        expect(response).to redirect_to(
          edit_trainee_subject_specialism_path(trainee, 2),
        )
      end
    end

    context "there are no more specialisms to choose" do
      let!(:course) { create(:course_with_subjects, subjects_count: 1) }

      # TODO: update this when  the confirm page exists
      it "redirects to the confirm page" do
        put(:update, params: { trainee_id: trainee, position: 1, subject_specialism_form: { specialism1: "moose" } })
        expect(response).to redirect_to(
          "www.example.com",
        )
      end
    end
  end
end
