# rubocop:disable Rails/ThreeStateBooleanColumn
# frozen_string_literal: true

class AddActiveColumnToDqtTeacherTrainings < ActiveRecord::Migration[7.0]
  def change
    add_column :dqt_teacher_trainings, :active, :boolean
  end
end
# rubocop:enable Rails/ThreeStateBooleanColumn
