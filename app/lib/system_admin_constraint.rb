# frozen_string_literal: true

class SystemAdminConstraint
  def matches?(request)
    signin_user = OtpSignInUser.load_from_session(request.session) ||
      DfESignInUser.load_from_session(request.session)
    signin_user&.system_admin?
  end
end
