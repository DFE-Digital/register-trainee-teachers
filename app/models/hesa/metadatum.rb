# frozen_string_literal: true

# == Schema Information
#
# Table name: hesa_metadata
#
#  id                           :bigint           not null, primary key
#  course_programme_title       :string
#  fundability                  :string
#  itt_aim                      :string
#  itt_qualification_aim        :string
#  pg_apprenticeship_start_date :date
#  placement_school_urn         :integer
#  service_leaver               :string
#  study_length                 :integer
#  study_length_unit            :string
#  year_of_course               :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  trainee_id                   :bigint
#
# Indexes
#
#  index_hesa_metadata_on_trainee_id  (trainee_id)
#
module Hesa
  class Metadatum < ApplicationRecord
    self.table_name = "hesa_metadata"

    belongs_to :trainee
  end
end
