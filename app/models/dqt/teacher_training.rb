# frozen_string_literal: true

# == Schema Information
#
# Table name: dqt_teacher_trainings
#
#  id                   :bigint           not null, primary key
#  programme_end_date   :string
#  programme_start_date :string
#  programme_type       :string
#  provider_ukprn       :string
#  result               :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  dqt_teacher_id       :bigint
#  hesa_id              :string
#
# Indexes
#
#  index_dqt_teacher_trainings_on_dqt_teacher_id  (dqt_teacher_id)
#
module Dqt
  class TeacherTraining < ApplicationRecord
    self.table_name = "dqt_teacher_trainings"

    belongs_to :dqt_teacher, class_name: "Dqt::Teacher", inverse_of: :dqt_trainings
  end
end
