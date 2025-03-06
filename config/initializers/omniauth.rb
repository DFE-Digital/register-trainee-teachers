# frozen_string_literal: true

require_relative "../../app/services/feature_service"

case Settings.features.sign_in_method
when "dfe-sign-in"

  OmniAuth.config.logger = Rails.logger

  dfe_sign_in_issuer_uri = URI.parse(Settings.dfe_sign_in.issuer)
  dfe_sign_in_issuer_uri_with_port = "#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}" if dfe_sign_in_issuer_uri.present?

  SETUP_PROC = lambda do |env|
    request = Rack::Request.new(env)

    dfe_sign_in_redirect_uri = URI.join(request.base_url, "/auth/dfe/callback")

    env["omniauth.strategy"].options.client_options = {
      port: dfe_sign_in_issuer_uri.port,
      scheme: dfe_sign_in_issuer_uri.scheme,
      host: dfe_sign_in_issuer_uri.host,
      identifier: Settings.dfe_sign_in.identifier,
      secret: Settings.dfe_sign_in.secret,
      redirect_uri: dfe_sign_in_redirect_uri,
    }
  end

  Rails.application.config.middleware.use(OmniAuth::Builder) do
    provider(:openid_connect, {
      name: :dfe,
      discovery: true,
      scope: %i[email profile],
      response_type: :code,
      path_prefix: "/auth",
      callback_path: "/auth/dfe/callback",
      issuer: dfe_sign_in_issuer_uri_with_port,
      setup: SETUP_PROC,
    })
  end

when "persona"

  Rails.application.config.middleware.use(OmniAuth::Builder) do
    provider(:developer,
             fields: %i[uid email first_name last_name],
             uid_field: :uid)
  end

end
