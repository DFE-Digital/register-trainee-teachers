# frozen_string_literal: true

# == Schema Information
#
# Table name: course_subjects
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :bigint           not null
#  subject_id :bigint           not null
#
# Indexes
#
#  index_course_subjects_on_course_id                 (course_id)
#  index_course_subjects_on_course_id_and_subject_id  (course_id,subject_id) UNIQUE
#  index_course_subjects_on_subject_id                (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class CourseSubject < ApplicationRecord
  belongs_to :course
  belongs_to :subject

  validates :course, uniqueness: { scope: :subject }
end
