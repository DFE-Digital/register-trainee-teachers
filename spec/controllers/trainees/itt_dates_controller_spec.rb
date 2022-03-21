# frozen_string_literal: true

require "rails_helper"

describe Trainees::IttDatesController do
  let(:user) { build_current_user }
  let(:trainee) { create(:trainee, :school_direct_salaried, provider: user.organisation) }

  let(:course) {
    create(:course,
           :with_full_time_dates,
           accredited_body_code: trainee.provider.code,
           route: trainee.training_route)
  }

  before do
    PublishCourseDetailsForm.new(trainee).assign_attributes_and_stash({ course_uuid: course.uuid })
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#edit" do
    context "with a course having full time itt dates" do
      it "redirects to the course confirmation page" do
        get :edit, params: { trainee_id: trainee.slug }
        expect(response).to redirect_to(trainee_publish_course_details_confirm_path(trainee))
      end
    end
  end
end
