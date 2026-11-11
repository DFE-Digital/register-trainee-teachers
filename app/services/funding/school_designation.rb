# frozen_string_literal: true

module Funding
  # Whether a trainee's employing school is on the year's list of disadvantaged
  # or special schools (Funding management → Funding schools management):
  #   :disadvantaged     — the school is on the list (as disadvantaged or special)
  #   :non_disadvantaged — the trainee has an employing school that isn't on the list
  #   :unknown           — no employing school yet, or "not applicable"
  # The values match FundingMethod#school_disadvantage.
  class SchoolDesignation
    def initialize(trainee, academic_cycle:)
      @trainee = trainee
      @academic_cycle = academic_cycle
    end

    def answer
      @answer ||=
        if !trainee.employing_school_recorded? || trainee.employing_school_not_applicable?
          :unknown
        elsif designation.present?
          :disadvantaged
        else
          :non_disadvantaged
        end
    end

    # Does a funding record's school designation fit the trainee? A blank value
    # applies to everyone; while the school is unknown either value fits.
    def matches?(funding_method)
      return true if funding_method.school_disadvantage.nil?
      return true if answer == :unknown

      funding_method.school_disadvantage.to_s == answer.to_s
    end

    # "Bluemeadow 2 High (URN 254333)", or the name alone when there's no URN.
    def school_label
      school = trainee.employing_school
      name = school&.name || trainee.employing_school_name
      urn = school&.urn || trainee.employing_school_urn
      urn.present? ? "#{name} (URN #{urn})" : name
    end

  private

    attr_reader :trainee, :academic_cycle

    def designation
      return @designation if defined?(@designation)

      @designation = if trainee.employing_school_id.present? && academic_cycle
                       FundingSchoolDesignation.find_by(school_id: trainee.employing_school_id, academic_cycle: academic_cycle)
                     end
    end
  end
end
