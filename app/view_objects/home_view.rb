# frozen_string_literal: true

class HomeView
  include Rails.application.routes.url_helpers

  attr_reader :badges, :action_badges, :current_user

  def initialize(trainees, current_user)
    @trainees = Trainees::Filter.call(trainees: trainees, filters: {})
    @current_user = current_user
    @trainees_cache_key_with_version = @trainees.cache_key_with_version

    create_badges

    if !current_user.system_admin? && !current_user.lead_school?
      create_action_badges
    else
      badges << incomplete_badge
    end
  end

  Badge = Struct.new(:status, :trainee_count, :link)

  def apply_drafts_link_text
    I18n.t(
      "landing_page.home.draft_apply_trainees_link",
      count: "",
      total: "",
    )
  end

private

  attr_reader :trainees, :trainees_cache_key_with_version

  def create_action_badges
    @action_badges = [
      Badge.new(
        :can_bulk_recommend_for_award,
        "",
        new_bulk_update_recommendations_upload_path,
      ),
      Badge.new(
        :can_complete,
        "",
        trainees_path(record_completion: %w[incomplete]),
      ),
    ]
  end

  def create_badges
    @badges = [
      Badge.new(
        :in_training,
        "",
        trainees_path(status: %w[in_training]),
      ),

      Badge.new(
        :awarded_this_year,
        "",
        trainees_path(
          status: %w[awarded],
          end_year: current_academic_cycle.label,
        ),
      ),

      Badge.new(
        :deferred,
        "",
        trainees_path(status: %w[deferred]),
      ),
    ]

    @badges.prepend(
      Badge.new(
        :course_not_started_yet,
        "",
        trainees_path(status: %w[course_not_yet_started]),
      ),
    )
  end

  def current_academic_cycle
    @current_academic_cycle ||= AcademicCycle.current
  end

  def incomplete_badge
    Badge.new(
      :incomplete,
      "",
      trainees_path(record_completion: %w[incomplete]),
    )
  end
end
