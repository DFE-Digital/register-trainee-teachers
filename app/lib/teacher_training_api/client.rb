# frozen_string_literal: true

module TeacherTrainingApi
  class Client
    include HTTParty
    base_uri Settings.teacher_training_api.base_url
    headers "User-Agent" => "Register for teacher training"
  end
end
