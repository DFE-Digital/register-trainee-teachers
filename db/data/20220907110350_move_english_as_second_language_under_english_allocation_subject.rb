# frozen_string_literal: true

class MoveEnglishAsSecondLanguageUnderEnglishAllocationSubject < ActiveRecord::Migration[6.1]
  def up
    AllocationSubject.find_by(name: AllocationSubjects::ENGLISH).tap do |allocation_subject|
      subject_specialism = SubjectSpecialism.find_by(name: PublishSubjects::ENGLISH_AS_SECOND_LANGUAGE)
      subject_specialism.update(allocation_subject:)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
