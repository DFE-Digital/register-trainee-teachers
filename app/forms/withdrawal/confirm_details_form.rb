# frozen_string_literal: true
module Withdrawal
  class ConfirmDetailsForm < TraineeForm

    FIELDS = [
      *DateForm::FIELDS,
      *ReasonForm::FIELDS,
      *ExtraInformationForm::FIELDS,
    ]

    attr_reader(:trainee, :reasons_form, :extra_information_form, :date_form)
    attr_accessor(*FIELDS)

    delegate :id, :itt_start_date, to: :trainee
    delegate :withdrawal_reasons, to: :reasons_form

    def initialize(trainee)
      @trainee = trainee
      @reasons_form = ReasonForm.new(trainee)
      @extra_information_form = ExtraInformationForm.new(trainee)
      @date_form = DateForm.new(trainee)
      @fields = compute_fields
      assign_attributes(fields)
    end

    def save!
      if valid?
        save_forms
        trainee.withdraw!
        Trainees::Withdraw.call(trainee:)
      else
        false
      end
    end

    def valid?
      return @valid if defined?(@valid)

      @valid = withdrawal_forms.all?(&:valid?)
    end

  private

    def withdrawal_forms
      @withdrawal_forms ||= [
        extra_information_form,
        reasons_form,
        date_form,
      ]
    end

    def save_forms
      withdrawal_forms.each(&:save!)
    end

    def compute_fields
      withdrawal_forms
        .map { |form| form.fields }
        .reduce({}, :merge)
        .slice(*FIELDS)
    end
  end
end
