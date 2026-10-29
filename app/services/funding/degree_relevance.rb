# frozen_string_literal: true

module Funding
  # Whether a trainee's degree is relevant to their course subject for funding,
  # using the year's relevant degree list (Funding management → Relevant degree
  # CAH management):
  #   :relevant       — a degree's HECoS code is on the list
  #   :unrelated      — the trainee has degrees and none are on the list
  #   :unknown        — no degree yet, on a route that needs one
  #   :not_applicable — undergraduate routes (no degree needed)
  class DegreeRelevance
    def initialize(trainee, academic_cycle:, allocation_subject:)
      @trainee = trainee
      @academic_cycle = academic_cycle
      @allocation_subject = allocation_subject
    end

    def answer
      @answer ||=
        if UNDERGRAD_ROUTES.key?(trainee.training_route.to_s)
          :not_applicable
        elsif degrees.empty?
          :unknown
        elsif hecos_codes.intersect?(relevant_hecos_codes)
          :relevant
        else
          :unrelated
        end
    end

    # The subject of the trainee's (first) degree, for messages.
    def degree_subject
      degrees.first&.subject
    end

    # The subject of the first degree that's on the relevant degree list, for messages.
    def relevant_degree_subject
      degrees.find { |degree| relevant_hecos_codes.include?(hecos_code(degree)) }&.subject
    end

    # The subjects of all the trainee's degrees, for messages.
    def degree_subjects
      degrees.filter_map(&:subject).uniq
    end

    # Does a funding record's degree relevance fit the trainee? A blank value
    # applies to everyone; while the degree is unknown either value fits.
    def matches?(funding_method)
      return true if funding_method.degree_relevance.nil?
      return true if answer == :unknown
      return false if answer == :not_applicable

      funding_method.degree_relevance.to_s == answer.to_s
    end

  private

    attr_reader :trainee, :academic_cycle, :allocation_subject

    # In the order they were added, so messages name them consistently.
    def degrees
      @degrees ||= trainee.degrees.to_a.sort_by { |degree| [degree.created_at || Time.zone.now, degree.id.to_i] }
    end

    def hecos_codes
      degrees.filter_map { |degree| hecos_code(degree) }
    end

    def hecos_code(degree)
      (DfEReference::DegreesQuery::SUBJECTS.one(degree.subject_uuid)&.hecos_code if degree.subject_uuid.present?) ||
        ::ReferenceData::DEGREE_SUBJECTS.hesa_code_for(degree.subject)
    end

    def relevant_hecos_codes
      return [] unless academic_cycle && allocation_subject

      @relevant_hecos_codes ||= RelevantDegreeMapping.where(academic_cycle:, allocation_subject:).pluck(:hecos_code)
    end
  end
end
