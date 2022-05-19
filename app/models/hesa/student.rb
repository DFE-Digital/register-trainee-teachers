# frozen_string_literal: true

module Hesa
  class Student < ApplicationRecord
    self.table_name = "hesa_students"

    belongs_to :trainee,
               foreign_key: :hesa_id,
               primary_key: :hesa_id,
               inverse_of: :hesa_student,
               optional: true,
               class_name: "::Student"
  end
end
