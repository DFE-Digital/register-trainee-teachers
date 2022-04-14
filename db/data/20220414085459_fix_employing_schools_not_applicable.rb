# frozen_string_literal: true

class FixEmployingSchoolsNotApplicable < ActiveRecord::Migration[6.1]
  def up
    dttp_trainees = Trainee.created_from_dttp.school_direct_salaried.where(employing_school_id: nil)

    # School Direct salaried that might have an employing school school that is not applicable
    dttp_trainees.each { |trainee| fix_trainee(trainee) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def fix_trainee(trainee)
    employing_school_dttp_id = trainee.dttp_trainee&.latest_placement_assignment&.employing_school_id
    employing_school_urn = Dttp::School.find_by(dttp_id: employing_school_dttp_id)&.urn

    trainee.update(employing_school_not_applicable: true) if %w[900010 99999996].include?(employing_school_urn)

    # It seems if we remove the 'zzz', the URN is actually valid and school records exist
    trainee.update(employing_school: School.find_by(urn: employing_school_urn.remove("zzz"))) if employing_school_urn&.include?("zzz")
  end
end
