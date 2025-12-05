# frozen_string_literal: true

class AddSchoolsDeletedToSchoolDataDownloads < ActiveRecord::Migration[7.2]
  def change
    add_column :school_data_downloads, :schools_deleted, :integer
  end
end
