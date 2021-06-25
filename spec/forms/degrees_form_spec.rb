# frozen_string_literal: true

require "rails_helper"

describe DegreesForm, type: :model do
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, form_store) }

  describe "validations" do
    context "degrees" do
      before do
        subject.valid?
      end

      context "with degrees" do
        before do
          trainee.degrees << build(:degree)
        end

        it { is_expected.to be_valid }
      end

      context "with no degrees" do
        it "returns an error if its empty" do
          expect(subject.errors[:degree_ids]).to include(
            I18n.t(
              "activemodel.errors.models.degrees_form.attributes.degree_ids.empty_degrees",
            ),
          )
        end
      end
    end
  end

  describe "#build_degree" do
    let(:template_degree) { build(:degree, :uk_degree_with_details) }

    it "returns new DegreeForm instance" do
      degree_form = subject.build_degree(
        locale_code: template_degree.locale_code,
        subject: template_degree.subject,
        institution: template_degree.institution,
        grade: template_degree.grade,
        graduation_year: template_degree.graduation_year,
      )
      expect(degree_form.locale_code).to eql(template_degree.locale_code)
      expect(degree_form.subject).to eql(template_degree.subject)
      expect(degree_form.institution).to eql(template_degree.institution)
      expect(degree_form.grade).to eql(template_degree.grade)
      expect(degree_form.graduation_year).to eql(template_degree.graduation_year)
    end
  end

  describe "#find_degree_from_param" do
    let(:degree1) { build(:degree, :uk_degree_with_details, trainee: trainee) }
    let(:degree2) { build(:degree, :non_uk_degree_with_details, trainee: trainee) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
      trainee.degrees << degree1
      trainee.degrees << degree2
      trainee.save!
    end

    it "find degree with slug and return DegreeForm instance" do
      expect(trainee.degrees.count).to be(2)

      degree_form = subject.find_degree_from_param(degree1.slug)
      expect(degree_form.slug).to eql(degree1.slug)
      expect(degree_form.class).to eql(DegreeForm)
      expect(degree_form.locale_code).to eql(degree1.locale_code)
      expect(degree_form.subject).to eql(degree1.subject)
      expect(degree_form.institution).to eql(degree1.institution)
      expect(degree_form.grade).to eql(degree1.grade)
      expect(degree_form.graduation_year).to eql(degree1.graduation_year)
    end

    describe "with stored attributes" do
      before do
        allow(form_store).to receive(:get).and_return({ degree1.slug => { subject: "This is stored" } })
      end

      it "find degree with slug and return DegreeForm instance" do
        expect(trainee.degrees.count).to be(2)

        degree_form = subject.find_degree_from_param(degree1.slug)
        expect(degree_form.slug).to eql(degree1.slug)
        expect(degree_form.class).to eql(DegreeForm)
        expect(degree_form.locale_code).to eql(degree1.locale_code)
        expect(degree_form.subject).to eql("This is stored")
        expect(degree_form.institution).to eql(degree1.institution)
        expect(degree_form.grade).to eql(degree1.grade)
        expect(degree_form.graduation_year).to eql(degree1.graduation_year)
      end
    end
  end

  describe "#degrees" do
    let(:degree1) { build(:degree, :uk_degree_with_details, trainee: trainee) }
    let(:degree2) { build(:degree, :non_uk_degree_with_details, trainee: trainee) }

    before do
      allow(form_store).to receive(:get).and_return({
        degree2.slug => { subject: "Edited saved degree" },
        "XXX111" => { slug: "XXX111", subject: "new unsaved degree" },
      })
      trainee.degrees << degree1
      trainee.degrees << degree2
      trainee.save!
    end

    it "returns all degrees including stored" do
      degrees = subject.degrees
      expect(degrees.count).to be(3)

      degree_form = degrees[0]
      expect(degree_form.slug).to eql(degree1.slug)
      expect(degree_form.class).to eql(DegreeForm)
      expect(degree_form.locale_code).to eql(degree1.locale_code)
      expect(degree_form.subject).to eql(degree1.subject)
      expect(degree_form.institution).to eql(degree1.institution)
      expect(degree_form.grade).to eql(degree1.grade)
      expect(degree_form.graduation_year).to eql(degree1.graduation_year)

      degree_form = degrees[1]
      expect(degree_form.slug).to eql(degree2.slug)
      expect(degree_form.class).to eql(DegreeForm)
      expect(degree_form.locale_code).to eql(degree2.locale_code)
      expect(degree_form.subject).to eql("Edited saved degree")
      expect(degree_form.institution).to eql(degree2.institution)
      expect(degree_form.grade).to eql(degree2.grade)
      expect(degree_form.graduation_year).to eql(degree2.graduation_year)

      degree_form = degrees[2]
      expect(degree_form.slug).to eql("XXX111")
      expect(degree_form.class).to eql(DegreeForm)
      expect(degree_form.locale_code).to be_blank
      expect(degree_form.subject).to eql "new unsaved degree"
      expect(degree_form.institution).to be_blank
      expect(degree_form.grade).to be_blank
      expect(degree_form.graduation_year).to be_blank
    end
  end

  describe "#stash_degree_on_store" do
    describe "empty store" do
      before do
        allow(form_store).to receive(:get).and_return(nil)
        allow(form_store).to receive(:set).with(trainee.id, :degrees, {
          "XXX111" => { "subject" => "test1" },
        })
      end

      it "store a new degree" do
        expect { subject.stash_degree_on_store("XXX111", { "subject" => "test1" }) }.not_to raise_exception
      end
    end

    describe "update degree" do
      before do
        allow(form_store).to receive(:get).and_return({
          "XXX111" => { "subject" => "stored degree" },
        })
        allow(form_store).to receive(:set).with(trainee.id, :degrees, {
          "XXX111" => { "subject" => "test1" },
        })
      end

      it "store a updated degree" do
        expect { subject.stash_degree_on_store("XXX111", { "subject" => "test1" }) }.not_to raise_exception
      end
    end

    describe "existing degree" do
      before do
        opts = {
          "XXX111" => { "subject" => "stored degree" },
        }
        allow(form_store).to receive(:get).and_return(opts)
        allow(form_store).to receive(:set).with(trainee.id, :degrees, opts.merge({
          "XXX112" => { "subject" => "test1" },
        }))
      end

      it "store a new degree" do
        expect { subject.stash_degree_on_store("XXX112", { "subject" => "test1" }) }.not_to raise_exception
      end
    end
  end

  describe "#delete_degree_on_store" do
    before do
      allow(form_store).to receive(:get).and_return({
        "XXX111" => { "subject" => "stored degree1" },
        "XXX112" => { "subject" => "stored degree2" },
      })
      allow(form_store).to receive(:set).with(trainee.id, :degrees, {
        "XXX112" => { "subject" => "stored degree2" },
      })
    end

    it "delete a degree" do
      expect { subject.delete_degree_on_store("XXX111") }.not_to raise_exception
    end
  end

  describe "#save!" do
    let(:degree_form1) { instance_double(DegreeForm) }
    let(:degree_form2) { instance_double(DegreeForm) }

    before do
      allow(degree_form1).to receive(:save!).and_return(true)
      allow(degree_form2).to receive(:save!).and_return(true)
      allow(subject).to receive(:degrees).and_return([degree_form1, degree_form2])
    end

    it "run save on all the degree form objects" do
      expect(subject.save!).to be_present
    end
  end
end
