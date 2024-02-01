module Api
  class TraineeAttributes
    include ActiveModel::Model

    ATTRIBUTES = %i[
      first_names
      middle_names
      last_name
      date_of_birth
      email
      sex
      trn
      training_route
      itt_start_date
      itt_end_date
      diversity_disclosure
      ethnic_group
      ethnic_background
      disability_disclosure
      course_subject_one
      course_subject_two
      course_subject_three
      study_mode
      application_choice_id
    ].freeze

    attr_accessor(*ATTRIBUTES)

    validates(*ATTRIBUTES, presence: true)
    validates :first_names, :last_name, length: { maximum: 50 }
    validates :middle_names, length: { maximum: 50 }, allow_nil: true
    validates :date_of_birth, date_of_birth: true
    validates :sex, inclusion: { in: Trainee.sexes.keys }
  end
end
