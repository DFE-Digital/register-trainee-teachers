# frozen_string_literal: true

# Demo funding for review apps (and local development), so the funding journeys
# can be tried without setting funding up by hand first:
#   - 2026 to 2027: the EYTDA grant for Year 1, 2 and 3, signed off (live)
#   - 2027 to 2028, left as a draft so it can be reviewed and signed off:
#     - Chemistry bursary depending on the degree (relevant £29,000, unrelated £15,000)
#     - Physics bursary only for a relevant degree (unrelated: not available)
#     - Chemistry scholarship (£31,000)
#     - Mathematics grant depending on the employing school
#       (disadvantaged or special £29,000, other schools £25,000)
#     - the relevant degree lists for Chemistry and Physics
#     - a school list of 3 schools (2 disadvantaged, 1 special)
# Safe to run more than once.
namespace :example_data do
  desc "Add demo funding: the 2026 to 2027 EYTDA grant, and 2027 to 2028 draft funding with relevant degree and school lists"
  task demo_funding: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    # One funding record for a route, type, split and subject.
    add = lambda do |cycle, route:, type:, method:, subject:, amount: nil, **split|
      allocation_subject = AllocationSubject.find_by!(name: subject)
      attributes = { training_route: route, funding_type: type, degree_relevance: split[:degree_relevance],
                     school_disadvantage: split[:school_disadvantage], training_year: split[:training_year] }
      record = cycle.funding_methods.joins(:allocation_subjects).find_by(attributes.merge(allocation_subjects: { id: allocation_subject.id })) ||
        cycle.funding_methods.new(attributes)
      record.funding_method = method
      record.availability = amount ? :available : :not_available
      record.amount = amount
      record.save!
      record.funding_method_subjects.find_or_create_by!(allocation_subject:)
    end

    # 2026 to 2027: the EYTDA grant, signed off.
    cycle2026 = AcademicCycle.for_year(2026)
    eytda = TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship]
    { 1 => 8_236, 2 => 8_236, 3 => 6_177 }.each do |year, amount|
      add.call(cycle2026, route: eytda, type: :grant, method: "E", subject: AllocationSubjects::EARLY_YEARS_ITT,
                          amount: amount, training_year: year)
    end
    cycle2026.update!(published: true)

    # 2027 to 2028: draft funding.
    cycle2027 = AcademicCycle.for_year(2027)
    fee_funded = TRAINING_ROUTE_ENUMS.values_at(:provider_led_postgrad, :school_direct_tuition_fee)
    salaried = TRAINING_ROUTE_ENUMS.values_at(:school_direct_salaried, :pg_teaching_apprenticeship)

    fee_funded.each do |route|
      add.call(cycle2027, route: route, type: :bursary, method: "D", subject: AllocationSubjects::CHEMISTRY, amount: 29_000, degree_relevance: :relevant)
      add.call(cycle2027, route: route, type: :bursary, method: "D", subject: AllocationSubjects::CHEMISTRY, amount: 15_000, degree_relevance: :unrelated)
      add.call(cycle2027, route: route, type: :bursary, method: "D", subject: AllocationSubjects::PHYSICS, amount: 29_000, degree_relevance: :relevant)
      add.call(cycle2027, route: route, type: :bursary, method: "D", subject: AllocationSubjects::PHYSICS, degree_relevance: :unrelated)
      add.call(cycle2027, route: route, type: :scholarship, method: "4", subject: AllocationSubjects::CHEMISTRY, amount: 31_000)
    end

    salaried.each do |route|
      add.call(cycle2027, route: route, type: :grant, method: "E", subject: AllocationSubjects::MATHEMATICS, amount: 29_000, school_disadvantage: :disadvantaged)
      add.call(cycle2027, route: route, type: :grant, method: "E", subject: AllocationSubjects::MATHEMATICS, amount: 25_000, school_disadvantage: :non_disadvantaged)
    end

    # 2027 to 2028: relevant degrees (every HECoS code under the CAH level 2 category).
    { AllocationSubjects::CHEMISTRY => %w[CAH07 CAH07-02], AllocationSubjects::PHYSICS => %w[CAH07 CAH07-01] }.each do |name, (level_1, level_2)|
      allocation_subject = AllocationSubject.find_by!(name:)
      Funding::CahReference.hecos_codes_for(level_2).each do |hecos_code|
        RelevantDegreeMapping.find_or_create_by!(academic_cycle: cycle2027, allocation_subject: allocation_subject, hecos_code: hecos_code) do |mapping|
          mapping.cah_level_1_code = level_1
          mapping.cah_level_2_code = level_2
        end
      end
    end

    # 2027 to 2028: the school list, from schools already in Register.
    schools = School.where(close_date: nil).order(:id).limit(3).to_a
    schools.zip(%i[disadvantaged disadvantaged special]).each do |school, designation|
      FundingSchoolDesignation.find_or_create_by!(academic_cycle: cycle2027, school: school) { |d| d.designation = designation }
    end

    puts "Demo funding: #{cycle2026.funding_methods.where(training_route: eytda).count} EYTDA records for 2026 to 2027 (signed off), " \
         "#{cycle2027.funding_methods.count} funding records for 2027 to 2028 (draft), " \
         "#{RelevantDegreeMapping.where(academic_cycle: cycle2027).count} relevant degrees and " \
         "#{FundingSchoolDesignation.where(academic_cycle: cycle2027).count} schools for 2027 to 2028"
  end
end
