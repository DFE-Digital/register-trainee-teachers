# frozen_string_literal: true

class AddHesaTrnSubmissionToTrainee < ActiveRecord::Migration[6.1]
  def change
    add_reference :trainees, :hesa_trn_submission, index: true, foreign_key: true
  end
end
