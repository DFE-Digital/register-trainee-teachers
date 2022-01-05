# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate
  before_action :check_organisation_context_is_set
  before_action :track_page
  after_action :save_origin_path
  include Pundit
  include EmitsRequestEvents

  rescue_from Pundit::NotAuthorizedError do
    render "errors/forbidden", status: :forbidden
  end

  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required? }

  helper_method :current_user, :authenticated?, :current_organisation, :audit_user

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
    @current_user ||= begin
                        return unless dfe_sign_in_user.present?

                        user = User.kept.find_by("LOWER(email) = ?", dfe_sign_in_user.email)
                        UserWithOrganisationContext.new(user: user, session: session)
                      end
  end

  def audit_user
    return nil unless current_user

    current_user.user
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

  def check_organisation_context_is_set
    return unless authenticated?

    redirect_to_organisation_contexts unless current_user.organisation.present? || current_user.system_admin?
  end

  def redirect_to_organisation_contexts
    if request.path !~ /#{organisation_contexts_path}/
      redirect_to(organisation_contexts_path)
    end
  end

  def authenticate
    save_requested_path_and_redirect unless authenticated?
  end

  def ensure_trainee_is_draft!
    redirect_to(trainee_path(trainee)) unless trainee.draft?
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
