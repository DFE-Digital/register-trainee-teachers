module Dttp
  class Client
    include HTTParty
    base_uri Settings.dttp.api_base_url
  end
end
