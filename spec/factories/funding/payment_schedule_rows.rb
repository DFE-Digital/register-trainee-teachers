# frozen_string_literal: true

FactoryBot.define do
  factory :payment_schedule_row, class: "Funding::PaymentScheduleRow" do
    sequence(:description) { |number| "Payment Schedule #{number}" }

    amounts { [build(:payment_schedule_row_amount)] }

    trait :for_full_year do
      amounts do
        month_order = Funding::PayablePaymentSchedulesImporter::MONTH_ORDER
        current_month_index = month_order.index(Time.zone.today.month)
        academic_cycle = AcademicCycle.current

        month_order.map.with_index do |month, index|
          build(
            :payment_schedule_row_amount,
            month: month,
            year: (1..7).include?(month) ? academic_cycle.end_date.year : academic_cycle.start_date.year,
            predicted: index > current_month_index,
          )
        end
      end
    end
  end
end
