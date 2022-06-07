# frozen_string_literal: true

class AddNewAllocationSubjectGeneralSciences < ActiveRecord::Migration[6.1]
  def up
    allocation_subject_name = AllocationSubjects::GENERAL_SCIENCES
    subject_specialisms = ALLOCATION_SUBJECT_SPECIALISM_MAPPING[allocation_subject_name]

    # Remove old mapping of existing specialisms
    SubjectSpecialism.where(name: subject_specialisms).delete_all

    # Move subject specialisms under new allocation subject
    AllocationSubject.create(name: allocation_subject_name).tap do |allocation_subject|
      subject_specialisms.each do |subject_specialism|
        allocation_subject.subject_specialisms.create(name: subject_specialism)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
