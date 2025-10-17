# frozen_string_literal: true

class RenameDqtTrnRequestsToTrsTrnRequests < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      rename_table :dqt_trn_requests, :trs_trn_requests
    end
  end
end
