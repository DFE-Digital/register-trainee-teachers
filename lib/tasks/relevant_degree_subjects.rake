# frozen_string_literal: true

namespace :relevant_degree_subjects do
  desc "Import relevant degree subjects from an uploaded CSV with allocation_subject and hecos_code headers. This only creates relevant degree subjects, it never updates or deletes them: changes like that need a custom request to a developer. rails 'relevant_degree_subjects:from_upload[upload_id,2027]'"
  task :from_upload, %i[upload_id academic_year] => :environment do |_, args|
    academic_cycle = AcademicCycle.for_year(args.academic_year)
    abort("No academic cycle found for #{args.academic_year}") if academic_cycle.nil?

    import = RelevantDegreeSubjects::ImportFromCsv.call(upload_id: args.upload_id, academic_cycle: academic_cycle)

    puts("Allocation subjects which do not match any in Register:")
    import.unmatched_allocation_subjects.uniq.each do |name|
      puts("  allocation_subject: #{name}")
    end

    puts("")
    puts("HECOS codes which are not valid degree subjects:")
    import.invalid_hecos_codes.uniq.each do |hecos_code|
      puts("  hecos_code: #{hecos_code}")
    end

    puts("")
    puts("Total number of rows not imported: #{(import.unmatched_allocation_subjects.count + import.invalid_hecos_codes.count).to_fs(:delimited)}")
  end
end
