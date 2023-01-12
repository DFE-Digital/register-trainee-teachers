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
    Rails.cache.fetch("#{@trainees.cache_key_with_version}/draft_trainees_count") do
      trainees.draft.size
    end
  end

  def draft_apply_trainees_count
    Rails.cache.fetch("#{@trainees.cache_key_with_version}/draft_apply_trainees_count") do
      trainees.draft.with_apply_application.size
    end
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

  def awarded_this_year_size
    Rails.cache.fetch("#{@trainees.cache_key_with_version}/awarded_this_year") do
      trainees.awarded.merge(current_academic_cycle.trainees_ending).size
    end
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

      Badge.new(
        :incomplete,
        incomplete_size,
        trainees_path(record_completion: %w[incomplete]),
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
    Rails.cache.fetch("#{@trainees.cache_key_with_version}/course_not_yet_started_size") do
      trainees.course_not_yet_started.size
    end
  end

  def deferred_size
    Rails.cache.fetch("#{@trainees.cache_key_with_version}/deferred_size") do
      trainees.deferred.size
    end
  end

  def drafts_are_all_apply_drafts?
    draft_apply_trainees_count == draft_trainees_count
  end

  def incomplete_size
    Rails.cache.fetch("#{@trainees.cache_key_with_version}/incomplete_size") do
      trainees.not_draft.incomplete.size
    end
  end

  def trainees_in_training_size
    Rails.cache.fetch("#{@trainees.cache_key_with_version}/trainees_in_training_size") do
      trainees.in_training.size
    end
  end
end
