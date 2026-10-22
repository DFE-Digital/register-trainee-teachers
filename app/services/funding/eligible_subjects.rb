# frozen_string_literal: true

module Funding
  # Which allocation subjects funding can be linked to, given the training
  # routes chosen in the Add funding wizard.
  #
  # Early years routes (EARLY_YEARS_TRAINING_ROUTES) only ever fund Early years
  # ITT, so the wizard sets that subject itself and skips the subjects step.
  # Every other route can use any active subject except Early years ITT. The
  # wizard never mixes early years routes with others (they lead to EYTS, and
  # QTS and EYTS funding are added separately).
  class EligibleSubjects
    def self.early_years?(routes)
      Array(routes).any? { |route| EARLY_YEARS_TRAINING_ROUTES.key?(route.to_s) }
    end

    def self.early_years_subject
      AllocationSubject.find_by(name: AllocationSubjects::EARLY_YEARS_ITT, deprecated_on: nil)
    end

    # True when the wizard can set the subject itself: early years routes and an
    # Early years ITT subject to set.
    def self.automatic?(routes)
      early_years?(routes) && early_years_subject.present?
    end

    def self.for(routes)
      active = AllocationSubject.where(deprecated_on: nil).order(:name)
      early_years?(routes) ? active.where(name: AllocationSubjects::EARLY_YEARS_ITT) : active.where.not(name: AllocationSubjects::EARLY_YEARS_ITT)
    end

    # The error for a subject selection, or nil when every subject fits the routes.
    def self.error_for(routes, subject_ids)
      ids = Array(subject_ids).compact_blank.map(&:to_i)
      return if ids.empty? || (ids - self.for(routes).pluck(:id)).empty?

      if early_years?(routes)
        "Select Early years ITT for early years training routes"
      else
        "Early years ITT is only for early years training routes"
      end
    end
  end
end
