# frozen_string_literal: true

module RecruitsApi
  class RetrieveApplications
    include ServicePattern

    def initialize(changed_since:, recruitment_cycle_year:)
      @changed_since = changed_since
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call
      applications
    end

  private

    attr_reader :changed_since, :recruitment_cycle_year

    def applications
      current_page = 1

      Enumerator.new do |enumerator|
        loop do
          response = get_response(current_page)
          JSON(response.body)["data"].each do |application_data|
            enumerator.yield(application_data)
          end

          page_count = response.headers["Total-Pages"]&.to_i || 1

          break unless page_count > current_page

          current_page += 1
        end

        log_request!
      end
    end

    def get_response(page = 1)
      @last_response = Client.get(params.merge(page:))
    end

    def params
      {
        recruitment_cycle_year: recruitment_cycle_year,
        changed_since: changed_since&.utc&.iso8601,
      }
    end

    def log_request!
      ApplyApplicationSyncRequest.create!(
        successful: @last_response.code == ApplyApi::Client::GET_SUCCESS,
        response_code: @last_response.code,
        recruitment_cycle_year: recruitment_cycle_year,
      )
    end
  end
end
