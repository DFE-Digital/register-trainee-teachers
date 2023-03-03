# frozen_string_literal: true

module Dqt
  class SyncTeacher
    include ServicePattern

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    # Why is HESA ID captured in both models?
    #
    # Teacher model represents 'contact' details in DQT and TeacherTraining represents 'initialteachertraining'
    #
    # So for example:
    #  - Trainee starts course 1 - contact HESA ID and training course 1 HESA ID align, in other words
    #    Teacher#hesa_id == TeacherTraining#hesa_id
    #  - Trainee withdraws from course 1 - contact HESA ID and training course 1 HESA ID remain aligned
    #  - Trainee starts course 2 - contact HESA ID now matches training course 2 HESA ID, whilst course 1
    #    HESA ID remains on the now inactivated 'older' withdrawn record
    def call
      dqt_data = RetrieveTeacher.call(trainee:)
      dqt_teacher = Teacher.find_or_initialize_by(trn: dqt_data["trn"], date_of_birth: dqt_data["dateOfBirth"])
      dqt_teacher.assign_attributes(first_name: dqt_data["firstName"],
                                    last_name: dqt_data["lastName"],
                                    hesa_id: dqt_data["husId"], # related to current training - dynamic
                                    qts_date: dqt_data["qtsDate"],
                                    eyts_date: dqt_data["eytsDate"],
                                    early_years_status_name: dqt_data.dig("earlyYearsStatus", "name"),
                                    early_years_status_value: dqt_data.dig("earlyYearsStatus", "value"))

      dqt_teacher.dqt_trainings = dqt_data["initialTeacherTraining"].map do |training_data|
        TeacherTraining.new(dqt_teacher: dqt_teacher,
                            programme_start_date: training_data["programmeStartDate"],
                            programme_end_date: training_data["programmeEndDate"],
                            programme_type: training_data["programmeType"],
                            result: training_data["result"],
                            active: training_data["active"],
                            hesa_id: training_data["husId"], # associated with that period of training
                            provider_ukprn: training_data.dig("provider", "ukprn"))
      end

      dqt_teacher.save
    end
  end
end
