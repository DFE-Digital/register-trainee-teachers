# frozen_string_literal: true

class ValidRegisterApiRoute
  def self.matches?(request)
    request[:api_version] == "v0.1"
  end
end
