# frozen_string_literal: true

class AddLevelFiveQualificationToTrainees < ActiveRecord::Migration[8.1]
  def change
    # Early years teacher degree apprenticeship (EYTDA) trainees declare whether
    # they hold a level 5 qualification. Empty until answered.
    add_column :trainees, :level_five_qualification, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn -- empty means not answered yet
  end
end
