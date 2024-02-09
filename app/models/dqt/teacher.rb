# frozen_string_literal: true

# == Schema Information
#
# Table name: dqt_teachers
#
#  id                       :bigint           not null, primary key
#  allowed_pii_updates      :boolean          default(FALSE), not null
#  date_of_birth            :string
#  early_years_status_name  :string
#  early_years_status_value :string
#  eyts_date                :string
#  first_name               :string
#  last_name                :string
#  qts_date                 :string
#  trn                      :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  hesa_id                  :string
#
# Indexes
#
#  index_dqt_teachers_on_allowed_pii_updates  (allowed_pii_updates)
#
module Dqt
  class Teacher < ApplicationRecord
    self.table_name = "dqt_teachers"

    belongs_to :trainee,
               foreign_key: :trn,
               primary_key: :trn,
               inverse_of: :dqt_teacher,
               optional: true

    has_many :dqt_trainings,
             primary_key: :id,
             foreign_key: :dqt_teacher_id,
             class_name: "Dqt::TeacherTraining",
             inverse_of: :dqt_teacher
  end
end
