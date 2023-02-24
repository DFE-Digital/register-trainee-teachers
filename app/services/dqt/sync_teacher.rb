# frozen_string_literal: true

module Dqt
  class SyncTeacher
    include ServicePattern

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      dqt_data = RetrieveTeacher.call(trainee:)
      dqt_teacher = Teacher.find_or_initialize_by(trn: dqt_data["trn"], date_of_birth: dqt_data["dateOfBirth"])
      dqt_teacher.assign_attributes(first_name: dqt_data["firstName"],
                                    last_name: dqt_data["lastName"],
                                    qts_date: dqt_data["qtsDate"],
                                    eyts_date: dqt_data["eytsDate"],
                                    early_years_status_name: dqt_data.dig("earlyYearsStatus", "name"),
                                    early_years_status_value: dqt_data.dig("earlyYearsStatus", "value"))
      dqt_teacher.save

      dqt_data["initialTeacherTraining"].each do |training_data|
        dqt_teacher_training = TeacherTraining.find_or_initialize_by(dqt_teacher:)
        dqt_teacher_training.assign_attributes(programme_start_date: training_data["programmeStartDate"],
                                               programme_end_date: training_data["programmeEndDate"],
                                               programme_type: training_data["programmeType"],
                                               result: training_data["result"],
                                               provider_ukprn: training_data.dig("provider", "ukprn"))
        dqt_teacher_training.save
      end
    end
  end
end
