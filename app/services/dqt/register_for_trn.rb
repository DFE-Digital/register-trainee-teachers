# frozen_string_literal: true

module Dqt
  class RegisterForTrn
    include ServicePattern

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_dqt)

      submit_trn_request
      update_trainee
    end

  private

    def submit_trn_request
      # https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L289
      # put request to ^
      request_id = SecureRandom.uuid
      path = "/v2/trn-requests/#{request_id}"

      # with params https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L503

          # "firstName":
          # "middleName":
          # "lastName":
          # "birthDate": #yyyy-mm-dd
          # "emailAddress":
          # "address": { # https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L547
          #   "addressLine1":
          #   "addressLine2":
          #   "addressLine3":
          #   "city":
          #   "postalCode":
          #   "country":
          # },
          # "genderCode": # "Male", "Female", "Other" https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L483
          # "initialTeacherTraining": {
          #   "providerUkprn":
          #   "programmeStartDate":
          #   "programmeEndDate":
          #   "programmeType": # https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L659
          #   "subject1":
          #   "subject2":
          #   "ageRangeFrom":
          #   "ageRangeTo":
          # },
          # "qualification": { #https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L621
          #   "providerUkprn":
          #   "countryCode":
          #   "subject":
          #   "class": #{ https://github.com/DFE-Digital/qualified-teachers-api/blob/main/docs/api-specs/v2.json#L411
          #   "date":
          # }
    end


    def update_trainee
      trainee.trn_requested!(contact_dttp_id, placement_assignment_dttp_id)
    end
  end
end
