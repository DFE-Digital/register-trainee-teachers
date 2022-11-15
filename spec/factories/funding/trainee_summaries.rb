# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_summary, class: "Funding::TraineeSummary" do
    academic_year { "#{(AcademicCycle.current || create(:academic_cycle, :current)).start_date.year}/#{(AcademicCycle.current || create(:academic_cycle, :current)).end_date.year % 100}" }

    trait :for_provider do
      payable { |p| p.association(:provider) }
    end

    trait :for_school do
      payable { |p| p.association(:school) }
    end

    trait :with_grant_rows do
      rows do
        [AllocationSubjects::CHEMISTRY, AllocationSubjects::BIOLOGY].map do |subject|
          build(:trainee_summary_row, :with_grant_amount, subject: subject)
        end
      end
    end

    trait :with_bursary_and_scholarship_rows do
      rows do
        bursaries = [AllocationSubjects::MATHEMATICS, AllocationSubjects::PHYSICS].map do |subject|
          build(:trainee_summary_row, :with_bursary_amount, subject: subject, lead_school_name: nil, lead_school_urn: nil)
        end
        scholarships = [build(:trainee_summary_row, :with_scholarship_amount, subject: AllocationSubjects::CHEMISTRY, route: "School Direct tuition fee")]
        tiered_bursaries = [build(:trainee_summary_row, :with_tiered_bursary_amount, subject: AllocationSubjects::CLASSICS)]

        bursaries + scholarships + tiered_bursaries
      end
    end
  end
end
