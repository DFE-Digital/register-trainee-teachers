# frozen_string_literal: true

class ReplaceProviderCodeWithAccreditedBodyCodeInApplyApplications < ActiveRecord::Migration[6.1]
  def change
    rename_column :apply_applications, :provider_code, :accredited_body_code
  end
end
