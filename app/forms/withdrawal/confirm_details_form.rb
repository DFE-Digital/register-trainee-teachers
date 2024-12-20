# frozen_string_literal: true

module Withdrawal
  class ConfirmDetailsForm < TraineeForm
    FIELDS = [
      *DateForm::FIELDS,
      *ReasonForm::FIELDS,
      *ExtraInformationForm::FIELDS,
    ].freeze

    attr_reader(:trainee, :reasons_form, :trigger_form, :date_form, :start_date_form)
    attr_accessor(*FIELDS)

    delegate :id, to: :trainee
    delegate :withdrawal_reasons, to: :reasons_form

    def initialize(trainee)
      @trainee = trainee
      @reasons_form = ReasonForm.new(trainee)
      @trigger_form = TriggerForm.new(trainee)
      @date_form = DateForm.new(trainee)
      @start_date_form = ::TraineeStartStatusForm.new(trainee)
      @fields = compute_fields
      assign_attributes(fields)
    end

    def save!
      if valid?
        ActiveRecord::Base.transaction do
          # Create empty withdrawal record that the forms can update
          trainee.trainee_withdrawals.create!
          save_forms
          trainee.withdraw!
          Trainees::Withdraw.call(trainee:)
        end
      else
        false
      end
    end

    def valid?
      return @valid if defined?(@valid)

      @valid = withdrawal_forms.all?(&:valid?)
    end

    def trainee_start_date
      start_date_form&.trainee_start_date || trainee.trainee_start_date
    end

  private

    def withdrawal_forms
      @withdrawal_forms ||= [
        trigger_form,
        reasons_form,
        date_form,
        (start_date_form unless exclude_start_date_form?),
      ].compact
    end

    def exclude_start_date_form?
      start_date_form.trainee_start_date == trainee.trainee_start_date
    end

    def save_forms
      withdrawal_forms.each(&:save!)
    end

    def compute_fields
      withdrawal_forms
        .map(&:fields)
        .reduce({}, :merge)
        .slice(*FIELDS)
    end
  end
end
