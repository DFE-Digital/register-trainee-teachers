# frozen_string_literal: true

class PageTracker
  HISTORY_KEY_PREFIX = "history_for"
  ORIGIN_PAGES_KEY_PREFIX = "origin_pages_for"
  TRAINEE_PAGE_URI_REGEX = /trainees\/.+/.freeze

  def initialize(trainee_slug:, session:, request:)
    @trainee_slug = trainee_slug
    @session = session
    @request = request
    @history_session_key = "#{HISTORY_KEY_PREFIX}_#{trainee_slug}"
    @origin_pages_session_key = "#{ORIGIN_PAGES_KEY_PREFIX}_#{trainee_slug}"

    clear_redundant_session_data unless on_trainee_specific_pages?
  end

  def save!
    return unless on_trainee_specific_pages?

    reset_history_to_current_path
    history << request.fullpath if request.get? && !history.include?(request.fullpath)
  end

  def save_as_origin!
    reset_origin_pages_to_current_path
    origin_pages << request.fullpath unless origin_pages.include?(request.fullpath)
  end

  def previous_page_path(consider_confirm_page: true)
    return last_origin_page_path if consider_confirm_page && entered_an_edit_page_directly?

    on_confirm_page? ? origin_pages[-2] : history[-2]
  end

  def last_origin_page_path
    # Edge case scenario of multiple confirm pages
    # If we have two confirm page paths return to first origin page
    return origin_pages.first if on_confirm_page? && another_confirm_page_in_history?
    return origin_pages[-2] if on_confirm_page?

    origin_pages.last
  end

  def last_non_confirm_origin_page_path
    origin_pages.reject { |path| path.include?("confirm") }.last
  end

  def remove_last_page
    history.pop
  end

private

  attr_reader :session, :request, :history_session_key, :origin_pages_session_key

  def on_confirm_page?
    request.fullpath.include?("confirm")
  end

  def on_trainee_specific_pages?
    request.fullpath.match(TRAINEE_PAGE_URI_REGEX)
  end

  def history
    session[history_session_key] ||= []
  end

  def origin_pages
    session[origin_pages_session_key] ||= []
  end

  def reset_history_to_current_path
    full_path_index = history.index(request.fullpath)
    session[history_session_key] = history[..full_path_index]
  end

  def reset_origin_pages_to_current_path
    full_path_index = origin_pages.index(request.fullpath)
    session[origin_pages_session_key] = origin_pages[..full_path_index]
  end

  def clear_redundant_session_data
    match = request.referer&.match(TRAINEE_PAGE_URI_REGEX)
    if match
      trainee_slug = match.to_s.split("/")[1]
      session.delete("#{HISTORY_KEY_PREFIX}_#{trainee_slug}")
      session.delete("#{ORIGIN_PAGES_KEY_PREFIX}_#{trainee_slug}")
    end
  end

  def entered_an_edit_page_directly?
    confirm_path = history.find { |path| path.include?("confirm") }
    edit_page_paths = history.select { |path| path.include?("edit") }

    confirm_path.nil? && edit_page_paths.size == 1
  end

  def another_confirm_page_in_history?
    confirm_paths = history.select { |path| path.include?("confirm") }
    confirm_paths.size > 1
  end
end
