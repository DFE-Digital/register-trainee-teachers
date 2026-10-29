# frozen_string_literal: true

# Course details can't be added or completed until what they depend on is
# complete (Trainees::CoursePrerequisites). Draft trainees are sent back to the
# draft record, which shows what to complete first.
module CoursePrerequisitesCheckable
  extend ActiveSupport::Concern

  included do
    before_action :check_course_prerequisites, if: :course_page?
  end

private

  def course_page?
    true
  end

  def check_course_prerequisites
    return unless trainee.draft?

    missing = Trainees::CoursePrerequisites.missing(trainee)
    return if missing.empty?

    redirect_to(trainee_review_drafts_path(trainee), flash: { course_prerequisites: missing.map(&:to_s) })
  end
end
