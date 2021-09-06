# frozen_string_literal: true

require "rails_helper"

module PublishCourseDetails
  describe View do
    include SummaryHelper

    context "with a publish course", feature_publish_course_details: true do
      let(:course) { create(:course_with_subjects, code: trainee.course_code, accredited_body_code: trainee.provider.code, route: training_route) }
      let(:unrelated_course) { create(:course_with_subjects, code: trainee.course_code) }
      let(:training_route) { TRAINING_ROUTES_FOR_COURSE.keys.sample }
      let(:trainee) { create(:trainee, :with_course_details, training_route: training_route) }

      before do
        course
        unrelated_course
        render_inline(View.new(data_model: trainee))
      end

      it "doesnt render the incorrect course details" do
        expect(rendered_component).not_to have_text("#{unrelated_course.name} (#{unrelated_course.code})")
      end

      it "render the correct course details" do
        expect(rendered_component).to have_text("#{course.name} (#{course.code})")
        expect(rendered_component).to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
        expect(rendered_component).to have_text(trainee.course_subject_one.upcase_first)
        expect(rendered_component).to have_text(age_range_for_summary_view(trainee.course_age_range))
        expect(rendered_component).to have_text(date_for_summary_view(trainee.course_start_date))
      end
    end
  end
end
