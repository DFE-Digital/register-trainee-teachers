# frozen_string_literal: true

module HesaStudentSummary
  class View < GovukComponent::Base
    attr_reader :trainee, :collection

    def initialize(trainee:, collection:)
      @trainee = trainee
      @collection = collection
    end

  private

    def hesa_trainee
      @hesa_trainee ||= trainee.hesa_student_for_collection(collection)
    end

    def student
      return [] if hesa_trainee.blank?

      @student ||= summarise(hesa_trainee.attributes.except("degrees", "placements", "created_at", "updated_at"))
    end

    def degrees
      return [] if hesa_trainee&.degrees.blank?

      @degrees ||= hesa_trainee.degrees.map { |degree| summarise(degree) }.flatten
    end

    def placements
      return [] if hesa_trainee&.placements.blank?

      @placements ||= hesa_trainee.placements.map { |placement| summarise(placement) }.flatten
    end

    # 4 December 2022 at 1:07pm
    def date
      hesa_trainee.created_at.strftime("%e %B %Y at %I:%M%P")
    end

    def summarise(data)
      summary = []

      data.each do |key, value|
        next if value.blank?

        summary << { key: { text: humanise(key) }, value: { text: value } }
      end

      summary
    end

    def humanise(key)
      key.humanize.gsub("Itt", "ITT").gsub("Hesa", "HESA")
    end
  end
end
