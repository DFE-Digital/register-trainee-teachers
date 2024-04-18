# frozen_string_literal: true

class ChangeHesaDisabilitiesToJson < ActiveRecord::Migration[7.1]
  def up
    safety_assured { remove_column :hesa_trainee_details, :hesa_disabilities }
    add_column :hesa_trainee_details, :hesa_disabilities, :jsonb, default: {}
  end

  def down
    safety_assured { remove_column :hesa_trainee_details, :hesa_disabilities }
    add_column :hesa_trainee_details, :hesa_disabilities, :string, default: [], array: true
  end
end
