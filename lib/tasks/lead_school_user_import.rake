# frozen_string_literal: true

namespace :user_import do
  desc "import lead school users from CSV and add them to lead school"
  task :lead_school_users, %i[csv_path] => [:environment] do |_, args|
    csv = CSV.read(args.csv_path, headers: true)
    missing_schools = LeadSchoolUserImport.call(attributes: csv)
    abort("School URNs: #{missing_schools.join(', ')} not found") unless missing_schools.empty?
  end
end
