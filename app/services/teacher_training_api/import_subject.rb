# frozen_string_literal: true

module TeacherTrainingApi
  class ImportSubject
    include ServicePattern

    def initialize(subject:)
      @attrs = subject[:attributes]
    end

    def call
      return unless code

      subject.update!(name: attrs[:name])
    end

  private

    attr_reader :attrs

    def subject
      @subject ||= Subject.find_or_initialize_by(code: code)
    end

    def code
      @code ||= attrs[:code]
    end
  end
end
