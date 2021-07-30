# frozen_string_literal: true

class SystemAdminConstraint
  def matches?(request)
    system_admin?(request)
  end

private

  def system_admin?(request)
    signin_user = DfESignInUser.load_from_session(request.session)
    signin_user.present? && User.system_admins.kept.exists?(email: signin_user.email)
  end
end
