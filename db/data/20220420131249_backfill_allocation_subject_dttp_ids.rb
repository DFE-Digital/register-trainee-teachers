# frozen_string_literal: true

class BackfillAllocationSubjectDttpIds < ActiveRecord::Migration[6.1]
  def up
    {
      AllocationSubjects::ART_AND_DESIGN => "aff10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::BIOLOGY => "b1f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::BUSINESS_STUDIES => "b3f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::CHEMISTRY => "b5f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::CLASSICS => "b9f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::COMPUTING => "bdf10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::DESIGN_AND_TECHNOLOGY => "c1f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::DRAMA => "c3f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::EARLY_YEARS_ITT => "fbf10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::ECONOMICS => "c5f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::ENGLISH => "c9f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::GEOGRAPHY => "cbf10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::HISTORY => "cff10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::MATHEMATICS => "d7f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::MODERN_LANGUAGES => "dbf10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::MUSIC => "ddf10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::OTHER_SUBJECTS => "e1f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::PHYSICAL_EDUCATION => "e3f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::PHYSICS => "e5f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::PRIMARY => "e9f10516-aac2-e611-80be-00155d010316",
      AllocationSubjects::PRIMARY_WITH_MATHEMATICS => "51d3114a-01b5-e811-812e-5065f38b6471",
      AllocationSubjects::RELIGIOUS_EDUCATION => "f7f10516-aac2-e611-80be-00155d010316",
    }.each do |name, dttp_id|
      AllocationSubject.find_by(name: name).update(dttp_id: dttp_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
