# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveSubjects
    include ServicePattern

    class Error < StandardError; end

    def call
      if response.code != 200
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body, symbolize_names: true)[:data]
    end

  private

    def response
      @response ||= Client.get("/subjects")
    end
  end
end
