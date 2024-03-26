# frozen_string_literal: true

# == Schema Information
#
# Table name: hesa_trainees
#
#  id                                 :bigint           not null, primary key
#  course_age_range                   :string
#  course_study_mode                  :string
#  course_year                        :integer
#  funding_method                     :string
#  itt_aim                            :string
#  ni_number                          :string
#  postgrad_apprenticeship_start_date :date
#  previous_last_name                 :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  trainee_id                         :bigint           not null
#
# Indexes
#
#  index_hesa_trainees_on_trainees_id  (trainees_id)
#
# Foreign Keys
#
#  fk_rails_...  (trainees_id => trainees.id)
#

module Hesa
  class TraineeDetail < ApplicationRecord
    self.table_name = "hesa_trainee_details"

    belongs_to :trainee
  end
end
