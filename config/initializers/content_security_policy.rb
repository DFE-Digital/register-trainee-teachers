# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap and inline scripts
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end

Rails.application.configure do
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

  config.content_security_policy do |policy|
    policy.default_src(:self)
    policy.connect_src(:self,
                       "https://www.google-analytics.com")
    policy.img_src(:self,
                   "https://www.google-analytics.com")
    policy.object_src(:none)
    policy.script_src(:self,
                      "https://www.googletagmanager.com",
                      "https://www.google-analytics.com",
                      "https://az416426.vo.msecnd.net") # needed for App Insights
    policy.style_src(:self, "'sha256-WAyOw4V+FqDc35lQPyRADLBWbuNK8ahvYEaQIYF1+Ps='") # Turbo progress bar stylesheet https://github.com/hotwired/turbo/issues/809
    policy.font_src(:self, :data)
    policy.upgrade_insecure_requests(!Rails.env.local?)
  end
end
