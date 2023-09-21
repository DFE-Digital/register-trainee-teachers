# frozen_string_literal: true

require "rails_helper"

describe Upload do
  context "scopes" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one_attached(:file) }
  end

  context "validations" do
    it { is_expected.to validate_presence_of(:file) }
    it { is_expected.to validate_presence_of(:name) }

    context "invalid file type" do
      let(:upload) { build(:upload, file: nil) }
      let(:file) { fixture_file_upload("test.txt", "text/plain") }

      before do
        upload.file.attach(file)
      end

      it "does not allow invalid content types" do
        expect(upload).not_to be_valid
        expect(upload.errors[:file]).to include("Upload a valid file type (csv, xml or zip)")
      end
    end

    context "valid file type" do
      subject { build(:upload) }

      it { is_expected.to be_valid }
    end

    context "invalid file size" do
      let(:upload) { build(:upload) }

      before do
        allow(upload.file.blob).to receive(:byte_size).and_return(51.megabytes)
      end

      it "does not allow invalid file size" do
        expect(upload).not_to be_valid
        expect(upload.errors[:file]).to include("Upload a file less than 50mb")
      end
    end
  end
end
