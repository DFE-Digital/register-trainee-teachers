# frozen_string_literal: true

module Support
  module TrsHelper
    def formatted_trs_trn_response(response)
      return if response.nil?

      result = if response["error"]
                 format_for_error(response)
               else
                 response
               end

      JSON.pretty_generate(result)
    end

  private

    def format_for_error(response)
      # Extract the parts of the string
      status = response["error"][/(?<=status: )\d+/]
      body = response["error"][/(?<=body: ).*?(?=, headers:)/]
      headers = response["error"][/(?<=headers: ).*$/]

      body = Rails.error.handle(StandardError, fallback: -> { {} }) do
        JSON.parse(body.gsub("=>", ":"))
      end

      headers = Rails.error.handle(StandardError, fallback: -> { {} }) do
        JSON.parse(headers.gsub("=>", ":"))
      end

      {
        error: {
          status: status.to_i,
          body: body,
          headers: headers,
        },
      }
    end
  end
end
