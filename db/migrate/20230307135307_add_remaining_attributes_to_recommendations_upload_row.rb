# frozen_string_literal: true

class AddRemainingAttributesToRecommendationsUploadRow < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_update_recommendations_upload_rows, :provider_trainee_id, :string
    add_column :bulk_update_recommendations_upload_rows, :last_names, :string
    add_column :bulk_update_recommendations_upload_rows, :first_names, :string
    add_column :bulk_update_recommendations_upload_rows, :lead_school, :string
    add_column :bulk_update_recommendations_upload_rows, :qts_or_eyts, :string
    add_column :bulk_update_recommendations_upload_rows, :route, :string
    add_column :bulk_update_recommendations_upload_rows, :phase, :string
    add_column :bulk_update_recommendations_upload_rows, :age_range, :string
    add_column :bulk_update_recommendations_upload_rows, :subject, :string

    add_reference :bulk_update_recommendations_upload_rows,
                  :matched_trainee,
                  foreign_key: { to_table: :trainees },
                  index: { name: :idx_bu_recommendations_upload_rows_on_matched_trainee_id }
  end
end
