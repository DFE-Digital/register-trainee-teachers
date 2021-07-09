# frozen_string_literal: true

require "rails_helper"

describe Trainees::SubjectSpecialismsController do
  let(:user) { create(:user) }
  let(:trainee) { create(:trainee, :provider_led_postgrad, :submitted_for_trn, provider: user.provider) }

  before do
    PublishCourseDetailsForm.new(trainee, params: { code: course.code }).stash
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#update" do
    context "with empty form params" do
      let!(:course) do
        create(
          :course_with_subjects,
          subjects_count: 1,
          accredited_body_code: trainee.provider.code,
          route: trainee.training_route,
        )
      end

      it "rerenders the page" do
        put(:update, params: { trainee_id: trainee, position: 1 })
        expect(response.code).to eq("200")
      end
    end

    context "there are more specialisms to choose" do
      let!(:course) do
        create(
          :course_with_subjects,
          subjects_count: 2,
          accredited_body_code: trainee.provider.code,
          route: trainee.training_route,
        )
      end

      it "redirects to the next position" do
        put(:update, params: { trainee_id: trainee, position: 1, subject_specialism_form: { specialism1: "moose" } })
        expect(response).to redirect_to(
          edit_trainee_subject_specialism_path(trainee, 2),
        )
      end
    end

    context "there are no more specialisms to choose" do
      let!(:course) do
        create(
          :course_with_subjects,
          subjects_count: 1,
          accredited_body_code: trainee.provider.code,
          subject_names: [Dttp::CodeSets::AllocationSubjects::ART_AND_DESIGN],
          route: trainee.training_route,
        )
      end

      # TODO: update this when  the confirm page exists
      it "redirects to the confirm page" do
        put(:update, params: { trainee_id: trainee, position: 1, subject_specialism_form: { specialism1: "moose" } })
        expect(response).to redirect_to(
          edit_trainee_confirm_publish_course_path(trainee_id: trainee.slug)
        )
      end
    end
  end
end
