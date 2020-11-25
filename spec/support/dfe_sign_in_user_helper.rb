# frozen_string_literal: true

module DfESignInUserHelper
  def set_authenticated_user(user: @current_user)
    mock_auth(user: user)
  end

  def mock_auth(user: @current_user)
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      fake_dfe_sign_in_auth_hash(
        email: user.email,
        dfe_sign_in_uid: user.dfe_sign_in_uid,
        first_name: user.first_name,
        last_name: user.last_name,
      ),
    )
  end

private

  def fake_dfe_sign_in_auth_hash(email:, dfe_sign_in_uid:, first_name:, last_name:)
    {
      "provider" => "dfe",
      "uid" => dfe_sign_in_uid,
      "info" => {
        "name" => "#{first_name} #{last_name}",
        "email" => email,
        "nickname" => nil,
        "first_name" => first_name,
        "last_name" => last_name,
        "gender" => nil,
        "image" => nil,
        "phone" => nil,
        "urls" => { "website" => nil },
      },
      "credentials" => {
        "id_token" => "",
        "token" => "DFE_SIGN_IN_TOKEN",
        "refresh_token" => nil,
        "expires_in" => 3600,
        "scope" => "email openid",
      },
      "extra" => {
        "raw_info" => {
          "email" => email,
          "sub" => dfe_sign_in_uid,
        },
      },
    }
  end
end
