# frozen_string_literal: true

class HomeView
  include Rails.application.routes.url_helpers

  attr_reader :badges, :action_badges, :current_user

  def initialize(trainees, current_user)
    @trainees = Trainees::Filter.call(trainees: trainees, filters: {})
    @current_user = current_user
    @trainees_cache_key_with_version = @trainees.cache_key_with_version

    create_badges

    if !current_user.system_admin? && !current_user.training_partner?
      create_action_badges
    else
      badges << incomplete_badge
    end
  end

  Badge = Struct.new(:status, :trainee_count, :link)

  def draft_trainees_count
    Rails.cache.fetch("#{trainees_cache_key_with_version}/draft_trainees_count", expires_in: 1.week) do
      trainees.draft.size
    end
  end

  def draft_apply_trainees_count
    Rails.cache.fetch("#{trainees_cache_key_with_version}/draft_apply_trainees_count", expires_in: 1.week) do
      trainees.draft.with_apply_application.size
    end
  end

  def apply_drafts_link_text
    if drafts_are_all_apply_drafts?
      I18n.t(
        "landing_page.home.draft_apply_trainees_link_all_apply",
        count: draft_apply_trainees_count,
      )
    else
      I18n.t(
        "landing_page.home.draft_apply_trainees_link",
        count: draft_apply_trainees_count,
        total: draft_trainees_count,
      )
    end
  end

private

  attr_reader :trainees, :trainees_cache_key_with_version

  def awarded_this_year_size
    Rails.cache.fetch("#{trainees_cache_key_with_version}/awarded_this_year", expires_in: 1.week) do
      trainees.awarded.merge(current_academic_cycle.trainees_ending).size
    end
  end

  def bulk_recommend_count
    Rails.cache.fetch("#{trainees_cache_key_with_version}/bulk_recommend_count", expires_in: 1.week) do
      Pundit.policy_scope(current_user, FindBulkRecommendTrainees.call).count
    end
  end

  def create_action_badges
    @action_badges = [
      Badge.new(
        :can_bulk_recommend_for_award,
        bulk_recommend_count,
        new_bulk_update_recommendations_upload_path,
      ),
      Badge.new(
        :can_complete,
        incomplete_size,
        trainees_path(record_completion: %w[incomplete]),
      ),
    ]
  end

  def create_badges
    @badges = [
      Badge.new(
        :in_training,
        trainees_in_training_size,
        trainees_path(status: %w[in_training]),
      ),

      Badge.new(
        :awarded_this_year,
        awarded_this_year_size,
        trainees_path(
          status: %w[awarded],
          end_year: current_academic_cycle.label,
        ),
      ),

      Badge.new(
        :deferred,
        deferred_size,
        trainees_path(status: %w[deferred]),
      ),
    ]

    if course_not_yet_started_size.positive?
      @badges.prepend(
        Badge.new(
          :course_not_started_yet,
          course_not_yet_started_size,
          trainees_path(status: %w[course_not_yet_started]),
        ),
      )
    end
  end

  def current_academic_cycle
    @current_academic_cycle ||= AcademicCycle.current
  end

  def course_not_yet_started_size
    Rails.cache.fetch("#{trainees_cache_key_with_version}/course_not_yet_started_size", expires_in: 1.week) do
      trainees.course_not_yet_started.size
    end
  end

  def deferred_size
    Rails.cache.fetch("#{trainees_cache_key_with_version}/deferred_size", expires_in: 1.week) do
      trainees.deferred.size
    end
  end

  def drafts_are_all_apply_drafts?
    draft_apply_trainees_count == draft_trainees_count
  end

  def incomplete_badge
    Badge.new(
      :incomplete,
      incomplete_size,
      trainees_path(record_completion: %w[incomplete]),
    )
  end

  def incomplete_size
    Rails.cache.fetch("#{trainees_cache_key_with_version}/incomplete_size", expires_in: 1.week) do
      trainees.not_draft.incomplete.size
    end
  end

  def trainees_in_training_size
    Rails.cache.fetch("#{trainees_cache_key_with_version}/trainees_in_training_size", expires_in: 1.week) do
      trainees.in_training.size
    end
  end
end
