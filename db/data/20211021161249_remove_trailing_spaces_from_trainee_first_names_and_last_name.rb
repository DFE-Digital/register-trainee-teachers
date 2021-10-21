# frozen_string_literal: true

class RemoveTrailingSpacesFromTraineeFirstNamesAndLastName < ActiveRecord::Migration[6.1]
  def up
    Trainee.without_auditing do # we don't want this save operation to be in audit trail
      Trainee.all.find_each(&:save) # auto_strip_attributes will remove all extra whitespace
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
