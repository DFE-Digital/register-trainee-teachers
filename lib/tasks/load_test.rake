# frozen_string_literal: true

namespace :load_test do
  desc "Create multiple bulk update trainee uploads in the background"
  task csv_trainee_upload: :environment do
    number_of_uploads = ENV["UPLOADS"].to_i || 2
    rows              = ENV["ROWS"].to_i || 100

    upload_ids = []

    data = -> do
      {
        "Provider Trainee ID" => "99157234/2/01",
        "Application ID" => nil,
        "HESA ID" => "0310261553101",
        "First Names" => "John",
        "Last Name" => SecureRandom.alphanumeric,
        "Previous Last Name" => "Smith",
        "Date of Birth" => "1990-01-01",
        "NI Number" => nil,
        "Sex" => "10",
        "Email" => "john.doe@example.com",
        "Nationality" => "GB",
        "Ethnicity" => nil,
        "Disability 1" => "58",
        "Disability 2" => "57",
        "Disability 3" => nil,
        "Disability 4" => nil,
        "Disability 5" => nil,
        "Disability 6" => nil,
        "Disability 7" => nil,
        "Disability 8" => nil,
        "Disability 9" => nil,
        "ITT Aim" => "202",
        "Training Route" => "11",
        "Qualification Aim" => "001",
        "Course Subject One" => "100346",
        "Course Subject Two" => nil,
        "Course Subject Three" => nil,
        "Study Mode" => "63",
        "ITT Start Date" => "2024-08-01",
        "ITT End Date" => "2025-08-01",
        "Course Age Range" => "13918",
        "Course Year" => "2012",
        "Lead Partner URN" => nil,
        "Employing School URN" => nil,
        "Trainee Start Date" => "2024-08-01",
        "PG Apprenticeship Start Date" => "2024-03-11",
        "Fund Code" => "2",
        "Funding Method" => "6",
        "Training Initiative" => nil,
        "Additional Training Initiative" => nil,
        "Placement 1 URN" => "900020",
        "Placement 2 URN" => nil,
        "Placement 3 URN" => nil,
        "UK Degree Type" => "083",
        "Non-UK Degree Type" => nil,
        "Degree Subject" => "100485",
        "Degree Grade" => "02",
        "Degree Graduation Year" => "2012",
        "Awarding Institution" => "0117",
        "Degree Country" => nil
      }
    end

    start_time = Time.current

    number_of_uploads.times do
      content = CSV.generate do |csv|
        csv << data.call.keys

        rows.times do
          csv << data.call.values
        end
      end

      tempfile = Tempfile.new(["load_test", "csv"])
      tempfile.write(content)
      tempfile.rewind

      uploaded_file = ActionDispatch::Http::UploadedFile.new(
        filename: "load_test.csv",
        tempfile: tempfile,
        type: "text/csv",
      )

      bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
        provider: Provider.last,
        file: uploaded_file,
      )

      if bulk_add_trainee_upload_form.save
        BulkUpdate::BulkAddTraineesImportRowsForm.new(
          upload: bulk_add_trainee_upload_form.upload,
        ).save

        upload_ids << bulk_add_trainee_upload_form.upload
      else
        raise "Something went wrong", bulk_add_trainee_upload_form.errors.full_messages
      end
    end

    uploads = BulkUpdate::TraineeUpload.where(id: upload_ids)

    puts "***Uploads validating***"

    while uploads.reload.exists?(status: :pending)
      print "."

      sleep 2
    end

    puts ""
    puts "***Uploads validated***"

    non_validated_uploads = uploads.where.not(status: :validated)

    if non_validated_uploads.any?
      raise "The following upload ids are not valid uploads #{non_validated_uploads.pluck(:id)}"
    end

    uploads.each do |upload|
      bulk_add_trainee_submit_form = BulkUpdate::BulkAddTraineesSubmitForm.new(
        upload: upload,
      )

      if bulk_add_trainee_submit_form.save
        puts "***Upload #{bulk_add_trainee_submit_form.upload.id} in progress***"
      else
        raise "Something went wrong with upload #{bulk_add_trainee_submit_form.upload.id}"
      end
    end

    while uploads.reload.exists?(status: :in_progress)
      print "."

      sleep 2
    end

    puts ""

    non_succeeded_uploads = uploads.where.not(status: :succeeded)

    if non_succeeded_uploads.any?
      raise "The following upload ids have not succeeded #{non_succeeded_uploads.pluck(:id)}"
    else
      puts "***Uploads succeeded 🎉 in #{((Time.current - start_time) / 60.0).round(2)} minutes***"
    end
  end
end
