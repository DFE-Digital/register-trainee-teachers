# frozen_string_literal: true

namespace :funding_school_designations do
  desc "Import disadvantaged and special schools from an uploaded CSV with urn and designation headers. This only creates designations, it never updates or deletes them: changes like that need a custom request to a developer. rails 'funding_school_designations:from_upload[upload_id,2027]'"
  task :from_upload, %i[upload_id academic_year] => :environment do |_, args|
    academic_cycle = AcademicCycle.for_year(args.academic_year)
    abort("No academic cycle found for #{args.academic_year}") if academic_cycle.nil?

    import = FundingSchoolDesignations::ImportFromCsv.call(upload_id: args.upload_id, academic_cycle: academic_cycle)

    puts("URNs which do not match any school in Register:")
    import.unmatched_urns.uniq.each do |urn|
      puts("  urn: #{urn}")
    end

    puts("")
    puts("Designations which are not disadvantaged or special:")
    import.invalid_designations.uniq.each do |designation|
      puts("  designation: #{designation}")
    end

    puts("")
    puts("URNs which already have a different designation in this academic cycle:")
    import.conflicting_urns.uniq.each do |urn|
      puts("  urn: #{urn}")
    end

    puts("")
    puts("Total number of rows not imported: #{(import.unmatched_urns.count + import.invalid_designations.count + import.conflicting_urns.count).to_fs(:delimited)}")
  end
end
