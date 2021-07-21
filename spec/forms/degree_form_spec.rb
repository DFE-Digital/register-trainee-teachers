# frozen_string_literal: true

require "rails_helper"

describe DegreeForm, type: :model do
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }
  let(:degrees_form) { DegreesForm.new(trainee, form_store) }
  let(:degree) { build(:degree, :uk_degree_with_details, trainee: trainee) }

  subject { DegreeForm.new(degrees_form: degrees_form, degree: degree) }

  describe "validations" do
    let(:degree) { Degree.new(locale_code: :uk) }

    it "requires subject to be present" do
      expect(subject.valid?).to be_falsey
      expect(subject.errors[:subject]).to be_present
      expect(subject.errors[:uk_degree]).to be_present
    end

    context "non_uk degree" do
      let(:degree) { Degree.new(locale_code: :non_uk) }

      it "requires the subject and country to be present" do
        expect(subject.valid?).to be_falsey
        expect(subject.errors[:subject]).to be_present
        expect(subject.errors[:country]).to be_present
      end
    end
  end

  describe "#initialize" do
    subject { DegreeForm.new(degrees_form: degrees_form, degree: Degree.new(subject: "Test")) }

    it "initialize with degree params" do
      expect(subject.subject).to eql("Test")
    end
  end

  describe "#fields" do
    subject { DegreeForm.new(degrees_form: degrees_form, degree: Degree.new(subject: "Test")) }

    it "return fields from initialize" do
      fields = subject.fields
      expect(fields[:subject]).to eql("Test")
    end

    it "return fields updated after initialize" do
      fields = subject.fields
      expect(fields[:subject]).to eql("Test")
      subject.subject = "updated test"
      fields = subject.fields
      expect(fields[:subject]).to eql("updated test")
    end
  end

  describe "#attributes" do
    subject { DegreeForm.new(degrees_form: degrees_form, degree: Degree.new) }

    it "return all attributes" do
      subject.attributes = {
        slug: "Test1",
        uk_degree: "Test2",
        non_uk_degree: "Test3",
        subject: "Test4",
        institution: "Test5",
        graduation_year: "Test6",
        grade: "Test7",
        other_grade: "Test8",
        country: "Test8",
        locale_code: "Test9",
      }

      expect(subject.attributes).to eql({
        slug: "Test1",
        uk_degree: "Test2",
        non_uk_degree: "Test3",
        subject: "Test4",
        institution: "Test5",
        graduation_year: "Test6",
        grade: "Test7",
        other_grade: "Test8",
        country: "Test8",
        locale_code: "Test9",
      })
    end
  end

  describe "#save_or_stash" do
    describe "draft" do
      before do
        allow(trainee).to receive(:draft?).and_return(true)
        allow(subject).to receive(:save!).and_return(true)
      end

      it "save!s" do
        expect(subject.save_or_stash).to be_truthy
      end
    end

    describe "not draft" do
      before do
        allow(trainee).to receive(:draft?).and_return(false)
        allow(subject).to receive(:stash).and_return(true)
      end

      it "stashes" do
        expect(subject.save_or_stash).to be_truthy
      end
    end
  end

  describe "#stash" do
    before do
      allow(subject).to receive(:fields).and_return({ subject: "test1" })
      allow(subject).to receive(:valid?).and_return(true)
      allow(degrees_form).to receive(:stash_degree_on_store).with(subject.slug, { subject: "test1" })
    end

    it "store degree" do
      expect(subject.stash).to be_present
    end
  end

  describe "#save!" do
    before do
      allow(degrees_form).to receive(:delete_degree_on_store).with(subject.slug)
      allow(subject).to receive(:valid?).and_return(true)
      allow(degree).to receive(:save!).with(context: subject.locale_code.to_sym).and_return(true)
    end

    it "save degree" do
      expect(subject.save!).to be_truthy
    end
  end

  describe "#destroy!" do
    before do
      allow(degrees_form).to receive(:delete_degree_on_store).with(subject.slug)
    end

    describe "new record" do
      before do
        allow(degree).to receive(:new_record?).and_return(true)
      end

      it "destroy degree" do
        expect(subject.destroy!).to be_nil
      end
    end

    describe "saved record" do
      before do
        allow(degree).to receive(:new_record?).and_return(false)
        allow(degree).to receive(:destroy!).and_return(true)
      end

      it "destroy degree" do
        expect(subject.destroy!).to be_truthy
      end
    end
  end

  describe "#save_and_return_invalid_data!" do
    before do
      allow(subject).to receive(:save_or_stash).and_return(true)
    end

    it "saves and returns a blank hash" do
      expect(subject).to receive(:save_or_stash)
      expect(subject.save_and_return_invalid_data!).to eq({})
    end

    context "when the trainee has invalid data" do
      let(:degree) { build(:degree, :uk_degree_with_details, trainee: trainee, institution: "Fake University") }

      it "saves and returns a hash containing invalid data" do
        expect(subject).to receive(:save_or_stash)
        expect(subject.save_and_return_invalid_data!).to eq({ institution: "Fake University" })
      end

      it "nullifies the invalid value" do
        expect {
          subject.save_and_return_invalid_data!
        }.to change { subject.institution }.from("Fake University").to(nil)
      end
    end
  end
end
