# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Confirmation
    module ConfirmPublishCourse
      describe View do
        alias_method :component, :page

        let(:course) { build(:course, duration_in_years: 2) }
        let(:trainee) { build(:trainee) }

        before do
          render_inline(View.new(trainee: trainee, course: course))
        end

        it "renders the course details" do
          expect(component.find(".govuk-summary-list__row.course-details .govuk-summary-list__value"))
            .to have_text("#{course.name} (#{course.code})")
        end

        it "renders the subject" do
          expect(component.find(".govuk-summary-list__row.subject .govuk-summary-list__value"))
            .to have_text(course.name)
        end

        it "renders the level" do
          expect(component.find(".govuk-summary-list__row.level .govuk-summary-list__value"))
            .to have_text(course.level.capitalize)
        end

        it "renders the age range" do
          expect(component.find(".govuk-summary-list__row.age-range .govuk-summary-list__value"))
            .to have_text(course.age_range)
        end

        it "renders the start date" do
          expect(component.find(".govuk-summary-list__row.start-date .govuk-summary-list__value"))
            .to have_text(course.start_date.strftime("%-d %B %Y"))
        end

        it "renders the duration" do
          expect(component.find(".govuk-summary-list__row.duration .govuk-summary-list__value"))
            .to have_text("#{course.duration_in_years} years")
        end
      end
    end
  end
end
