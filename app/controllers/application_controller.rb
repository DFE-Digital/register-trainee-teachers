# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate
  before_action :track_page

  include Pundit

  rescue_from Pundit::NotAuthorizedError do
    render "errors/forbidden", status: :forbidden
  end

  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  helper_method :current_user, :authenticated?

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def enforce_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      BasicAuthenticable.authenticate(username, password)
    end
  end

  def dfe_sign_in_user
    @dfe_sign_in_user ||= DfESignInUser.load_from_session(session)
  end

  def current_user
    @current_user ||= User.find_by(email: dfe_sign_in_user&.email)
  end

  def authenticated?
    current_user.present?
  end

  def authenticate
    redirect_to sign_in_path unless authenticated?
  end

  def ensure_trainee_is_draft!
    redirect_to trainee_path(trainee) unless trainee.draft?
  end

  def ensure_trainee_is_not_draft!
    redirect_to review_draft_trainee_path(trainee) if trainee.draft?
  end

  def track_page
    page_tracker.save!
  end

  def page_tracker
    @page_tracker ||= begin
      trainee_slug = params[:trainee_id] || params[:id]
      PageTracker.new(trainee_slug: trainee_slug, session: session, request: request)
    end
  end

  def session_form_stash_key
    "#{trainee.slug}_form_changes"
  end

  def stash_form_changes
    session[session_form_stash_key] = { action: trainee.own_and_associated_audits.first.action, changes: trainee.own_and_associated_audits.first.audited_changes }
  end

  def clear_stash
    session[session_form_stash_key] = nil
  end

  def cancel_form_changes
    return if params[:cancel].blank? || session[session_form_stash_key].blank?

    stash = trainee.own_and_associated_audits.where(action: session[session_form_stash_key]["action"], audited_changes: session[session_form_stash_key]["changes"])
    return if stash.empty?

    stash.first.undo
    clear_stash
  end
end
