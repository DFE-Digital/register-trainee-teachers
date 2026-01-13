# frozen_string_literal: true

# == Schema Information
#
# Table name: hesa_students
#
#  id                           :bigint           not null, primary key
#  allocated_place              :string
#  bursary_level                :string
#  collection_reference         :string
#  commencement_date            :string
#  course_age_range             :string
#  course_programme_title       :string
#  course_subject_one           :string
#  course_subject_three         :string
#  course_subject_two           :string
#  date_of_birth                :string
#  degrees                      :json
#  disability1                  :string
#  disability2                  :string
#  disability3                  :string
#  disability4                  :string
#  disability5                  :string
#  disability6                  :string
#  disability7                  :string
#  disability8                  :string
#  disability9                  :string
#  email                        :string
#  employing_school_urn         :string
#  end_date                     :string
#  ethnic_background            :string
#  first_names                  :string
#  fund_code                    :string
#  hesa_committed_at            :string
#  hesa_updated_at              :string
#  initiatives_two              :string
#  itt_aim                      :string
#  itt_commencement_date        :string
#  itt_end_date                 :string
#  itt_key                      :string
#  itt_qualification_aim        :string
#  itt_start_date               :string
#  last_name                    :string
#  mode                         :string
#  nationality                  :string
#  ni_number                    :string
#  numhus                       :string
#  pg_apprenticeship_start_date :string
#  placements                   :json
#  previous_surname             :string
#  reason_for_leaving           :string
#  service_leaver               :string
#  sex                          :string
#  status                       :string
#  study_length                 :string
#  study_length_unit            :string
#  surname16                    :string
#  trainee_start_date           :string
#  training_initiative          :string
#  training_partner_urn         :string
#  training_route               :string
#  trn                          :string
#  ttcid                        :string
#  ukprn                        :string
#  year_of_course               :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  application_choice_id        :string
#  hesa_id                      :string
#  previous_hesa_id             :string
#  provider_course_id           :string
#  provider_trainee_id          :string
#  rec_id                       :string
#
# Indexes
#
#  index_hesa_students_on_hesa_id_and_rec_id  (hesa_id,rec_id) UNIQUE
#
module Hesa
  class Student < ApplicationRecord
    self.table_name = "hesa_students"
    self.ignored_columns += %w[student_instance_id]

    belongs_to :trainee,
               foreign_key: :hesa_id,
               primary_key: :hesa_id,
               inverse_of: :hesa_students,
               optional: true

    scope :latest, -> { order(collection_reference: :desc).first }
  end
end
