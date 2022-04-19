# frozen_string_literal: true

class AddFundingMethodsForAncientLanguages < ActiveRecord::Migration[6.1]
  def up
    classics_allocation_subject = AllocationSubject.find_by(name: AllocationSubjects::CLASSICS)
    ancient_languages_allocation_subject = AllocationSubject.find_by(name: AllocationSubjects::ANCIENT_LANGUAGES)

    # Copy all the funding methods from Classics until we enter the 22/23 academic year
    classics_allocation_subject.funding_methods.where(academic_cycle: AcademicCycle.current).each do |funding_method|
      ancient_languages_allocation_subject.funding_method_subjects.create(funding_method: funding_method)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
