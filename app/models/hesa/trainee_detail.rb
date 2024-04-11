# frozen_string_literal: true

# == Schema Information
#
# Table name: hesa_trainee_details
#
#  id                                 :bigint           not null, primary key
#  additional_training_initiative     :string
#  course_age_range                   :string
#  course_study_mode                  :string
#  course_year                        :integer
#  fund_code                          :string
#  funding_method                     :string
#  hesa_disabilities                  :string           default([]), is an Array
#  itt_aim                            :string
#  itt_qualification_aim              :string
#  ni_number                          :string
#  postgrad_apprenticeship_start_date :date
#  previous_last_name                 :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  trainee_id                         :bigint           not null
#
# Indexes
#
#  index_hesa_trainee_details_on_trainee_id  (trainee_id)
#
# Foreign Keys
#
#  fk_rails_...  (trainee_id => trainees.id)
#

module Hesa
  class TraineeDetail < ApplicationRecord
    self.table_name = "hesa_trainee_details"

    belongs_to :trainee
  end
end
