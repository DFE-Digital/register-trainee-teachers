# frozen_string_literal: true

module SchoolDetails
  class View < ApplicationComponent
    include SchoolHelper
    include TrainingPartnerHelper

    attr_reader :trainee, :training_partner, :employing_school, :has_errors, :editable

    def initialize(trainee:, has_errors: false, editable: false)
      @trainee = trainee
      @training_partner = trainee.training_partner
      @employing_school = trainee.employing_school
      @has_errors = has_errors
      @editable = editable
    end

    def school_rows
      [
        training_partner_row(not_applicable: trainee.training_partner_not_applicable?),
        employing_school_row(not_applicable: trainee.employing_school_not_applicable?),
      ].compact
    end

  private

    def change_paths(school_type)
      {
        training_partner: edit_trainee_training_partners_path(trainee),
        employing: edit_trainee_employing_schools_path(trainee),
      }[school_type.to_sym]
    end
  end
end
