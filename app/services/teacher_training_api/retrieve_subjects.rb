# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveSubjects
    include ServicePattern

    def call
      JSON(response.body, symbolize_names: true)[:data]
    end

  private

    def response
      @response ||= Client.get("/subjects")
    end
  end
end
