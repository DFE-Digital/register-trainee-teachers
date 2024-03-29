# frozen_string_literal: true

require_relative "../../app/services/feature_service"

case Settings.features.sign_in_method
when "dfe-sign-in"

  OmniAuth.config.logger = Rails.logger

  dfe_sign_in_issuer_uri = URI.parse(Settings.dfe_sign_in.issuer)
  dfe_sign_in_redirect_uri = URI.join(Settings.base_url, "/auth/dfe/callback")
  dfe_sign_in_issuer_uri_with_port = "#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}" if dfe_sign_in_issuer_uri.present?

  client_options = {
    identifier: Settings.dfe_sign_in.identifier,

    port: dfe_sign_in_issuer_uri.port,
    scheme: dfe_sign_in_issuer_uri.scheme,
    host: dfe_sign_in_issuer_uri.host,

    secret: Settings.dfe_sign_in.secret,
    redirect_uri: dfe_sign_in_redirect_uri&.to_s,
  }

  options = {
    name: :dfe,
    discovery: true,
    response_type: :code,
    scope: %i[email profile],
    path_prefix: "/auth",
    callback_path: "/auth/dfe/callback",
    client_options: client_options,
    issuer: dfe_sign_in_issuer_uri_with_port,
  }.compact

  Rails.application.config.middleware.use(OmniAuth::Strategies::OpenIDConnect, options)

when "persona"

  Rails.application.config.middleware.use(OmniAuth::Builder) do
    provider(:developer,
             fields: %i[uid email first_name last_name],
             uid_field: :uid)
  end

end
