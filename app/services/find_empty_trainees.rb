# frozen_string_literal: true

class FindEmptyTrainees
  include ServicePattern

  attr_reader :trainees, :ids_only, :forms

  def initialize(trainees: Trainee.all, ids_only: false)
    @trainees = trainees
    @ids_only = ids_only
    @forms = compile_progress_validation_forms
  end

  def call
    trainees.draft.filter_map do |trainee|
      if trainee_empty?(trainee)
        ids_only ? trainee.id : trainee
      end
    end
  end

private

  def trainee_empty?(trainee)
    forms.all? do |progress_type, form|
      progress_value = trainee.progress.public_send(progress_type)
      ProgressService.call(validator: form.new(trainee), progress_value: progress_value).not_started?
    end
  end

  def compile_progress_validation_forms
    TrnSubmissionForm.form_validators.transform_values { |form_details| form_details[:form].constantize }
  end
end
