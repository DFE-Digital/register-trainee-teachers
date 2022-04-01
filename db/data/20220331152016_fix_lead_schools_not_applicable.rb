# frozen_string_literal: true

class FixLeadSchoolsNotApplicable < ActiveRecord::Migration[6.1]
  def up
    dttp_trainees = Trainee.created_from_dttp.where(lead_school_id: nil)

    # Teaching apprenticeships that are missing a lead school
    dttp_trainees.pg_teaching_apprenticeship.where.not(employing_school_id: nil).each { |trainee| fix_trainee(trainee) }

    # School Direct that might have a lead school that is not applicable
    dttp_trainees.school_direct_tuition_fee.or(Trainee.school_direct_salaried).each { |trainee| fix_trainee(trainee) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def fix_trainee(trainee)
    lead_school_dttp_id = trainee.dttp_trainee&.latest_placement_assignment&.lead_school_id
    lead_school_urn = Dttp::School.find_by(dttp_id: lead_school_dttp_id)&.urn

    trainee.update(lead_school_not_applicable: true) if %w[900010 99999996].include?(lead_school_urn)

    # It seems if we remove the 'zzz', the URN is actually valid and school records exist
    trainee.update(lead_school: School.find_by(urn: lead_school_urn.remove("zzz"))) if lead_school_urn&.include?("zzz")

    # The following URN's don't have a matching school but when checked against
    # https://get-information-schools.service.gov.uk/Search we find school names that do exist in the schools table
    # with a different URN.
    trainee.update(lead_school: School.find_by(name: "Chellaston Academy")) if lead_school_urn == "148639"
    trainee.update(lead_school: School.find_by(name: "Greentrees Primary School")) if lead_school_urn == "148680"
    trainee.update(lead_school: School.find_by(name: "Redwell Primary School")) if lead_school_urn == "148611"
  end
end
