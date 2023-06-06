# frozen_string_literal: true
module Withdrawal
  class ConfirmDetailsForm < TraineeForm

    FIELDS = [
      *DateForm::FIELDS,
      *Reasonform::FIELDS,
      *ExtraInformationForm::FIELDS,
    ]

    attr_reader :trainee, :withdrawal_forms

    def initialize(trainee)
      @trainee = trainee

      @date_form = DateForm.new(trainee)
      @reasons_form = ReasonForm.new(trainee)
      @extra_information_form = ExtraInformationForm.new(trainee)

      @withdrawal_forms = [
        @date_form,
        @reasons_form,
        @extra_information_form,
      ]
    end


    def itt_start_date
      trainee.itt_start_date
    end

    def withdraw_date
      @date_form.withdraw_date
    end

    def reasons
      @reasons_form.reasons
    end

    def withdraw_reasons_details
      @extra_information_form.withdraw_reasons_details
    end

    def withdraw_reasons_dfe_details
      @extra_information_form.withdraw_reasons_dfe_details
    end

  private

    def clear_stash
          
    end

    def compute_fields
      
    end
  end
end
