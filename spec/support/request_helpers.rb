# frozen_string_literal: true

module RequestHelpers
  def api_get(version, endpoint, params: {}, token: "Bearer bat")
    get "/api/v#{version}/#{endpoint}", params: params, headers: { Authorization: token }
  end

  def api_post(version, endpoint, params: {}, token: "Bearer bat")
    post "/api/v#{version}/#{endpoint}", params: params, headers: { Authorization: token }
  end
end
