# frozen_string_literal: true

require "rails_helper"

module PublishCourseDetails
  describe View do
    include SummaryHelper

    context "with a publish course", feature_publish_course_details: true do
      let(:course) { trainee.published_course }
      let(:trainee) { create(:trainee, :with_publish_course_details) }

      before do
        render_inline(View.new(data_model: trainee))
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
