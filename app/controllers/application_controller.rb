# frozen_string_literal: true

class ApplicationController < ActionController::Base
  if FeatureService.performance_testing?
    prepend ApplicationControllerDev
    content_security_policy false
  end

  before_action :authenticate
  before_action :track_page
  before_action :check_organisation_context_is_set
  after_action :save_origin_path
  include Pundit::Authorization
  include DfE::Analytics::Requests

  rescue_from Pundit::NotAuthorizedError do
    render "errors/forbidden.html", status: :forbidden
  end

  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  helper_method :current_user, :authenticated?, :audit_user, :trainee_editable?

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

private

  def save_origin_path
    session[:origin_path] = request.original_fullpath
  end

  def user_came_from_backlink?
    session[:origin_path]&.include?("edit")
  end

  def enforce_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      BasicAuthenticable.authenticate(username, password)
    end
  end

  def dfe_sign_in_user
    @dfe_sign_in_user ||= DfESignInUser.load_from_session(session)
  end

  def current_user
    return if dfe_sign_in_user.blank?

    @current_user ||= begin
      user = lookup_user_by_dfe_sign_in_uid || lookup_user_by_email
      UserWithOrganisationContext.new(user: user, session: session) if user.present?
    end
  end

  def lookup_user_by_dfe_sign_in_uid
    return nil if dfe_sign_in_user&.dfe_sign_in_uid.blank?

    User.kept.find_by(
      "LOWER(dfe_sign_in_uid) = ?",
      dfe_sign_in_user.dfe_sign_in_uid.downcase,
    )
  end

  def lookup_user_by_email
    return nil if dfe_sign_in_user&.email.blank?

    User.kept.find_by(
      "LOWER(email) = ?",
      dfe_sign_in_user.email.downcase,
    )
  end

  def audit_user
    current_user&.user
  end

  def authenticated?
    current_user.present?
  end

  def save_requested_path
    session[:requested_path] = request.fullpath
  end

  def save_requested_path_and_redirect
    save_requested_path
    redirect_to(sign_in_path)
  end

  def authenticate
    save_requested_path_and_redirect unless authenticated?
  end

  def check_organisation_context_is_set
    return unless authenticated?

    redirect_to_organisation_contexts unless current_user.organisation.present? || current_user.system_admin?
  end

  def redirect_to_organisation_contexts
    if request.path !~ /#{organisations_path}/
      redirect_to(organisations_path)
    end
  end

  def ensure_trainee_is_draft!
    redirect_to(trainee_path(trainee)) unless trainee.draft?
  end

  def trainee_editable?
    @trainee_editable ||= policy(trainee).update?
  end

  def ensure_trainee_is_not_draft!
    redirect_to(trainee_review_drafts_path(trainee)) if trainee.draft?
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

  def clear_form_stash(trainee)
    FormStore.clear_all(trainee.id)
  end
end
