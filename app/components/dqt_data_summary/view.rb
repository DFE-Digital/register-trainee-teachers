# frozen_string_literal: true

module DqtDataSummary
  class View < GovukComponent::Base
    def initialize(dqt_data:)
      @dqt_data = dqt_data
    end

  private

    attr_reader :trainee, :dqt_data

    def general
      @general ||= summarise(dqt_data.except("qualified_teacher_status", "induction", "initial_teacher_training", "qualifications"))
    end

    def qualified_teacher_status
      return [] if dqt_data["qualified_teacher_status"].nil?

      @qualified_teacher_status ||= summarise(dqt_data["qualified_teacher_status"])
    end

    def induction
      return [] if dqt_data["induction"].nil?

      @induction ||= summarise(dqt_data["induction"])
    end

    def initial_teacher_training
      return [] if dqt_data["initial_teacher_training"].nil?

      @initial_teacher_training ||= summarise(dqt_data["initial_teacher_training"])
    end

    def qualifications
      return [] if dqt_data["qualifications"].nil?

      @qualifications ||= dqt_data["qualifications"].map { |qualification| summarise(qualification) }.flatten
    end

    def qualification_count
      return if dqt_data["qualifications"].empty?

      dqt_data["qualifications"].count
    end

    def itt_result
      dqt_data["initial_teacher_training"].present? ? dqt_data["initial_teacher_training"]["result"] : "-"
    end

    def qts_date
      dqt_data["qts_date"].present? ? Date.parse(dqt_data["qts_date"]) : "-"
    end

    def date_of_birth
      Date.parse(dqt_data["dob"]).strftime("%e %B %Y")
    end

    # 4 December 2022 at 1:07pm
    def date
      Time.zone.now.strftime("%e %B %Y at %I:%M%P")
    end

    def summarise(data)
      summary = []

      data.each do |key, value|
        summary << { key: { text: key, classes: "no-wrap govuk-!-width-one-third" }, value: { text: value.presence || "-" } }
      end

      summary
    end
  end
end
