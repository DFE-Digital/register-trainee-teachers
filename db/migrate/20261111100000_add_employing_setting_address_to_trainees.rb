# frozen_string_literal: true

class AddEmployingSettingAddressToTrainees < ActiveRecord::Migration[8.1]
  def change
    # Early years teacher degree apprenticeship (EYTDA): the address of the
    # apprentice employing setting, which may be a nursery without a URN.
    add_column :trainees, :employing_school_address_line_one, :string
    add_column :trainees, :employing_school_address_line_two, :string
    add_column :trainees, :employing_school_town, :string
  end
end
