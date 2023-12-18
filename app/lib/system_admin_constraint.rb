# frozen_string_literal: true

class SystemAdminConstraint
  def matches?(request)
    system_admin?(request)
  end

private

  def system_admin?(request)
    signin_user =
      if otp_feature_enabled?
        OtpSignInUser.load_from_session(request.session)
      else
        DfESignInUser.load_from_session(request.session)
      end

    signin_user.present? && User.system_admins.kept.exists?(email: signin_user.email)
  end

  def otp_feature_enabled?
    Settings.features.sign_in_method == "otp"
  end
end
