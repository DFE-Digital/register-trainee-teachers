# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe SyncStudents do
    subject(:service) { described_class.call }
    let(:xml_file_path) { Rails.root.join("spec/support/fixtures/hesa/itt_record.xml") }
    let(:xml_response) { File.read(xml_file_path) }
    let(:url) do
      [
        Settings.hesa.collection_base_url,
        Settings.hesa.current_collection_reference,
        Settings.hesa.current_collection_start_date,
      ].join("/")
    end

    before do
      allow(::Hesa::Client).to receive(:get).with(url:).and_return(xml_response)
    end

    describe ".call" do
      it "fetches the collection XML and creates a Hesa::Student record" do
        expect { described_class.call }.to change { Student.count }.from(0).to(1)
      end

      context "XML is empty" do
        let(:xml_response) { "" }

        it "doesn't try to parse the XML response" do
          expect { described_class.call }.not_to raise_error
        end
      end

      context "hesa record spanning two collections" do
        let!(:hesa_student) { create(:hesa_student, hesa_id: "0310261553101", rec_id: "16054") }

        it "creates new collection record" do
          expect { described_class.call }.to change { Student.count }.from(1).to(2)
        end
      end

      context "hesa record with an alternative hesa id in an existing collection" do
        let!(:hesa_student) { create(:hesa_student, hesa_id: "0000000000000", previous_hesa_id: "0310261553101", rec_id: "16053") }

        before do
          allow(Hesa::Parsers::IttRecord).to receive(:to_attributes).and_return(
            hesa_id: "0310261553101",
            rec_id: "16053",
          )
        end

        it "updates the existing record and moves the old hesa_id to previous_hesa_id" do
          expect { service }.not_to change { Student.count }
          expect(hesa_student.reload.hesa_id).to eq "0310261553101"
          expect(hesa_student.previous_hesa_id).to eq "0000000000000"
        end
      end

      context "hesa record with the same hesa id in an existing collection" do
        let!(:hesa_student) { create(:hesa_student, hesa_id: "0310261553101", rec_id: "16053") }

        it "updates the existing record and does not update the hesa ids" do
          expect { service }.not_to change { Student.count }
          expect(hesa_student.reload.hesa_id).to eq "0310261553101"
          expect(hesa_student.previous_hesa_id).to be_nil
        end
      end

      context "hesa record with a different hesa_id but matching combined fields in an existing collection" do
        let!(:hesa_student) do
          create(
            :hesa_student,
            hesa_id: "0000000000000",
            rec_id: "16053",
            first_names: "Dave",
            last_name: "George",
            date_of_birth: "1978-08-13",
            trainee_id: "99157234/2/01",
            ukprn: "10007713",
            itt_commencement_date: nil,
            numhus: "02",
            email: "student.name@email.com",
          )
        end

        it "updates the existing record and moves the old hesa_id to previous_hesa_id" do
          expect { service }.not_to change { Student.count }
          expect(hesa_student.reload.hesa_id).to eq "0310261553101"
          expect(hesa_student.previous_hesa_id).to eq "0000000000000"
        end
      end

      context "hesa record with a different hesa_id but matching combined fields in a new collection" do
        let!(:hesa_student) do
          create(
            :hesa_student,
            hesa_id: "0310261553101",
            rec_id: "16053",
            first_names: "Dave",
            last_name: "George",
            date_of_birth: "1978-08-13",
            trainee_id: "99157234/2/01",
            ukprn: "10007713",
            itt_commencement_date: nil,
            numhus: "02",
            email: "student.name@email.com",
          )
        end

        before do
          allow(Hesa::Parsers::IttRecord).to receive(:to_attributes).and_return(
            hesa_id: "0310261553101",
            rec_id: "16054", # different rec_id,
            first_names: "Dave",
            last_name: "George",
            date_of_birth: "1978-08-13",
            trainee_id: "99157234/2/01",
            ukprn: "10007713",
            itt_commencement_date: nil,
            numhus: "02",
            email: "student.name@email.com",
          )
        end

        it "updates the existing record and moves the old hesa_id to previous_hesa_id" do
          expect { service }.not_to change { Student.count }
        end
      end

      context "hesa record with the same hesa_id but different additional info in an existing collection" do
        let!(:hesa_student) do
          create(
            :hesa_student,
            hesa_id: "0310261553101",
            rec_id: "16053",
            first_names: "Dave",
            last_name: "George",
            date_of_birth: "1978-08-13",
            trainee_id: "99157234/2/01",
            ukprn: "10007713",
            itt_commencement_date: nil,
            numhus: "02",
            email: "student.name@email.com",
          )
        end

        before do
          allow(Hesa::Parsers::IttRecord).to receive(:to_attributes).and_return(
            hesa_id: "0310261553101",
            rec_id: "16053",
            first_names: "New Name",
            last_name: "New Surname",
            date_of_birth: "1980-08-13",
            trainee_id: "99157234/2/01",
            ukprn: "10007713",
            itt_commencement_date: nil,
            numhus: "02",
            email: "student.name@email.com",
          )
        end

        it "updates the existing record with new additional info" do
          expect { service }.not_to change { Student.count }
          expect(hesa_student.reload.first_names).to eq "New Name"
          expect(hesa_student.last_name).to eq "New Surname"
          expect(hesa_student.date_of_birth).to eq "1980-08-13"
        end
      end

      context "with an optional upload" do
        let(:filename) { "itt_record.xml" }
        let(:upload) { create(:upload, name: filename, file: nil) }

        before do
          upload.file.attach(
            io: File.open(xml_file_path),
            filename: filename, content_type: file_type
          )
        end

        context "with an xml file type" do
          let(:file_type) { "text/xml" }

          it "uses the uploaded xml to create students" do
            expect { described_class.call(upload_id: upload.id) }.to change { Student.count }.from(0).to(1)
          end

          it "sets collection reference correctly" do
            described_class.call(upload_id: upload.id)

            expect(Student.first.collection_reference).to eq("C16053")
          end
        end

        context "with a zip file type" do
          let(:file_type) { "application/zip" }
          let(:filename) { "itt_record.zip" }

          it "uses the uploaded xml to create students" do
            expect { described_class.call(upload_id: upload.id) }.to change { Student.count }.from(0).to(1)
          end
        end
      end
    end
  end
end
