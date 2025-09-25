# frozen_string_literal: true

module HesaStudentSummary
  class View < ApplicationComponent
    def initialize(trainee:, collection:)
      @trainee = trainee
      @collection = collection
    end

  private

    attr_reader :trainee, :collection

    def hesa_trainee
      @hesa_trainee ||= trainee.hesa_student_for_collection(collection)
    end

    def student
      return [] if hesa_trainee.blank?

      @student ||= summarise(hesa_trainee.attributes.except("degrees", "placements", "created_at", "updated_at", "id"))
    end

    def degrees
      return [] if hesa_trainee&.degrees.blank?

      @degrees ||= hesa_trainee.degrees.map { |degree| summarise(degree) }.flatten
    end

    def degree_count
      return if degrees.empty?

      hesa_trainee.degrees.count
    end

    def placements
      return [] if hesa_trainee&.placements.blank?

      @placements ||= hesa_trainee.placements.map { |placement| summarise(placement) }.flatten
    end

    def placement_count
      return if placements.empty?

      hesa_trainee.placements.count
    end

    # 4 December 2022 at 1:07pm
    def date
      hesa_trainee.updated_at.strftime("%e %B %Y at %I:%M%P")
    end

    def summarise(data)
      data.map do |key, value|
        { key: { text: humanise(key) }, value: { text: value.presence || "-" } }
      end
    end

    def humanise(key)
      key = key.humanize.downcase

      {
        "itt" => "ITT",
        "hesa" => "HESA",
        "urn" => "URN",
        "ukprn" => "UKPRN",
        "trn" => "TRN",
        "pg" => "PG",
      }.each do |k, v|
        key.sub!(k, v)
      end

      key
    end
  end
end
