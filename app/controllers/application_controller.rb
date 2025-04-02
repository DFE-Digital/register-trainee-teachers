# frozen_string_literal: true

class ApplicationController < ActionController::Base
  if FeatureService.performance_testing?
    prepend ApplicationControllerDev
    content_security_policy false
  end

  before_action :authenticate
  before_action :track_page
  before_action :check_organisation_context_is_set
  before_action :set_sentry_organisation_context, unless: -> { Rails.env.local? }
  after_action :save_origin_path
  include Pundit::Authorization
  include DfE::Analytics::Requests
  include Codespaceable

  rescue_from Pundit::NotAuthorizedError do
    render "errors/forbidden", status: :forbidden, formats: [:html]
  end

  before_action :enforce_basic_auth, if: -> { BasicAuthenticable.required?(request.path) }

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

  # dfe and otp objects can both be instantiated as `.begin_session!` will always create
  # a session with a dfe/otp_sign_in_user hash regardless of there being a user/email.
  # We only want to memoize the instance that responds to #user hence the `.select`
  def sign_in_user
    @sign_in_user ||= [
      DfESignInUser.load_from_session(session),
      OtpSignInUser.load_from_session(session),
    ].select { it.try(:user) }.first
  end

  def current_user
    @current_user ||= if sign_in_user
                        Current.user = UserWithOrganisationContext.new(
                          user: sign_in_user.user,
                          session: session,
                        )
                      end
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

  def set_sentry_organisation_context
    return unless defined?(current_user) && current_user&.organisation.present?

    Sentry.set_tags(organisation: current_user.organisation.name)
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
      PageTracker.new(trainee_slug:, session:, request:)
    end
  end

  def clear_form_stash(trainee)
    FormStore.clear_all(trainee.id)
  end

  def require_feature_flag(feature)
    redirect_to(not_found_path) unless FeatureService.enabled?(feature)
  end
end
