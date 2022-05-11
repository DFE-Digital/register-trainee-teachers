# frozen_string_literal: true

class BackfillHesaMetadata
  def call
    Trainee.where(created_from_dttp: true).where.not(hesa_id: nil).where(hesa_updated_at: nil).each do |trainee|
      latest_placement_assignment = trainee.dttp_trainee.latest_placement_assignment
      hesa_metadatum = Hesa::Metadatum.find_or_initialize_by(trainee: trainee)
      study_length = latest_placement_assignment.response["dfe_programmelength"]
      hesa_metadatum.assign_attributes(study_length: study_length,
                                       study_length_unit: study_length >= 12 ? "months" : "years",
                                       itt_aim: Dttp::CodeSets::IttAims::MAPPING[latest_placement_assignment.response["_dfe_ittaimid_value"]],
                                       itt_qualification_aim: Dttp::CodeSets::IttAims::MAPPING[latest_placement_assignment.response["_dfe_ittqualificationaimid_value"]],
                                       fundability: Dttp::CodeSets::Fundability::MAPPING[latest_placement_assignment.response["_dfe_fundabilityid_value"]],
                                       course_programme_title: latest_placement_assignment.response["dfe_programmetitleofcourse"],
                                       pg_apprenticeship_start_date: latest_placement_assignment.response["dfe_apprenticeshipstartdate"],
                                       year_of_course: latest_placement_assignment.response["dfe_programmeyear"])
      hesa_metadatum.save
    end
  end
end
