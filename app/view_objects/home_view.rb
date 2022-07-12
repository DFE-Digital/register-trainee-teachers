# frozen_string_literal: true

class HomeView
  include Rails.application.routes.url_helpers

  attr_reader :badges

  def initialize(trainees)
    @trainees = Trainees::Filter.call(trainees: trainees, filters: {})
    create_badges
  end

  Badge = Struct.new(:status, :trainee_count, :link)

  def draft_trainees_count
    @draft_trainees_count ||= trainees.draft.count
  end

  def draft_apply_trainees_count
    @draft_apply_trainees_count ||= trainees.draft.with_apply_application.count
  end

  def apply_drafts_link_text
    if drafts_are_all_apply_drafts?
      I18n.t(
        "pages.home.draft_apply_trainees_link_all_apply",
        count: draft_apply_trainees_count,
      )
    else
      I18n.t(
        "pages.home.draft_apply_trainees_link",
        count: draft_apply_trainees_count,
        total: draft_trainees_count,
      )
    end
  end

private

  attr_reader :trainees

  def create_badges
    @badges = [
      Badge.new(
        :in_training,
        trainees.in_training.count,
        trainees_path(status: %w[in_training]),
      ),

      Badge.new(
        :awarded_this_year,
        trainees.awarded.merge(current_academic_cycle.trainees_ending).count,
        trainees_path(
          status: %w[awarded],
          end_year: current_academic_cycle.label,
        ),
      ),

      Badge.new(
        :deferred,
        trainees.deferred.count,
        trainees_path(status: %w[deferred]),
      ),

      Badge.new(
        :incomplete,
        trainees.not_draft.incomplete_for_filter.count,
        trainees_path(record_completion: %w[incomplete]),
      ),
    ]

    if course_not_yet_started_count.positive?
      @badges.prepend(
        Badge.new(
          :course_not_started_yet,
          course_not_yet_started_count,
          trainees_path(status: %w[course_not_yet_started]),
        ),
      )
    end
  end

  def current_academic_cycle
    @current_academic_cycle ||= AcademicCycle.current
  end

  def course_not_yet_started_count
    @course_not_yet_started_count ||= trainees.course_not_yet_started.count
  end

  def drafts_are_all_apply_drafts?
    draft_apply_trainees_count == draft_trainees_count
  end
end
