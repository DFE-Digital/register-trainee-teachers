# frozen_string_literal: true

class ApplyTraineeDataForm
  include ActiveModel::Model

  attr_accessor :mark_as_reviewed

  def initialize(trainee:)
    @trainee = trainee
  end

  def save
    trainee.progress.personal_details = true
    trainee.progress.contact_details = true
    trainee.progress.diversity = true
    trainee.progress.degrees = true
    trainee.save!
  end

  def section_status(_)
    :in_progress
  end

private

  attr_reader :trainee
end
