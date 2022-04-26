# frozen_string_literal: true

class AddNewAllocationSubjectAncientLanguages < ActiveRecord::Migration[6.1]
  def up
    allocation_subject = AllocationSubjects::ANCIENT_LANGUAGES
    subject_specialisms = ALLOCATION_SUBJECT_SPECIALISM_MAPPING[allocation_subject]

    # Remove old mapping of existing specialisms
    SubjectSpecialism.where(name: subject_specialisms).delete_all

    # Move subject specialisms under new allocation subject
    AllocationSubject.create(name: allocation_subject).tap do |as|
      subject_specialisms.each do |subject_specialism|
        as.subject_specialisms.create(name: subject_specialism)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
