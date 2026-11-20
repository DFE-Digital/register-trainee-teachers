# frozen_string_literal: true

# Demo funding for local/review so the degree/school split journeys can be tried
# without waiting on signed-off 2027 to 2028 amounts:
#   - Chemistry bursary split by degree (relevant £29,000 / unrelated £15,000)
#   - Chemistry scholarship (£31,000, everyone)
#   - Mathematics grant split by employing school (listed £29,000 / other £25,000)
#   - relevant degree HECoS for Chemistry
#   - a small school designation list
#
# Does not clash with relevant_degree_subjects:from_upload (#9996) or a future
# production amounts migration — those own real data; this is find_or_create demo only.
# Safe to run more than once: rails example_data:demo_funding
namespace :example_data do
  desc "Add demo funding with degree/school splits for local and review apps"
  task demo_funding: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    cycle = AcademicCycle.for_year(2027) || AcademicCycle.current || raise("No academic cycle available")

    add = lambda do |route:, type:, subject:, amount:, degree_relevance: nil, school_disadvantage: nil|
      allocation_subject = AllocationSubject.find_by!(name: subject)
      funding_method = FundingMethod.find_or_create_by!(
        training_route: route,
        funding_type: type,
        academic_cycle: cycle,
        degree_relevance:,
        school_disadvantage:,
        amount:,
      )
      funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
    end

    fee_funded = TRAINING_ROUTE_ENUMS.values_at(:provider_led_postgrad, :school_direct_tuition_fee)
    salaried = TRAINING_ROUTE_ENUMS.values_at(:school_direct_salaried, :pg_teaching_apprenticeship)

    fee_funded.each do |route|
      add.call(route:, type: :bursary, subject: AllocationSubjects::CHEMISTRY, amount: 29_000, degree_relevance: :relevant)
      add.call(route:, type: :bursary, subject: AllocationSubjects::CHEMISTRY, amount: 15_000, degree_relevance: :unrelated)
      add.call(route:, type: :scholarship, subject: AllocationSubjects::CHEMISTRY, amount: 31_000)
    end

    salaried.each do |route|
      add.call(route:, type: :grant, subject: AllocationSubjects::MATHEMATICS, amount: 29_000, school_disadvantage: :disadvantaged)
      add.call(route:, type: :grant, subject: AllocationSubjects::MATHEMATICS, amount: 25_000, school_disadvantage: :non_disadvantaged)
    end

    chemistry = AllocationSubject.find_by!(name: AllocationSubjects::CHEMISTRY)
    # Chemistry HECoS codes used in API/UI specs
    %w[100417 101050].each do |hecos_code|
      RelevantDegreeSubject.find_or_create_by!(academic_cycle: cycle, allocation_subject: chemistry, hecos_code:)
    end

    School.where(close_date: nil).order(:id).limit(3).each_with_index do |school, index|
      designation = index == 2 ? :special : :disadvantaged
      FundingSchoolDesignation.find_or_create_by!(academic_cycle: cycle, school:) do |record|
        record.designation = designation
      end
    end

    puts "Demo funding for #{cycle.label}: " \
         "#{cycle.funding_methods.where.not(degree_relevance: nil).or(cycle.funding_methods.where.not(school_disadvantage: nil)).count} split funding records, " \
         "#{RelevantDegreeSubject.where(academic_cycle: cycle).count} relevant degrees, " \
         "#{FundingSchoolDesignation.where(academic_cycle: cycle).count} school designations"
  end
end
