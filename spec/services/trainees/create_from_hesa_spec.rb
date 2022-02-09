# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromHesa do
    let(:itt_record_doc) { read_fixture_file("hesa/itt_record.xml") }
    let(:itt_record_xml_attributes) { Hesa::Parsers::IttRecord.to_attributes(itt_record_doc: itt_record_doc) }
    let(:nationality_name) { ApplyApi::CodeSets::Nationalities::MAPPING[itt_record_xml_attributes[:nationality]] }
    let(:training_route) { Hesa::CodeSets::TrainingRoutes::MAPPING[itt_record_xml_attributes[:training_route]] }
    let(:trainee) { Trainee.first }

    before { create(:nationality, name: nationality_name) }

    context "trainee already exists and didn't come from HESA" do
      before do
        create(:trainee, hesa_id: itt_record_xml_attributes[:hesa_id])
        described_class.call(itt_record_doc: itt_record_doc)
      end

      it "updates the trainee from HESA XML document" do
        expect(trainee.created_from_hesa).to be(false)
        expect(trainee.hesa_id).to eq(itt_record_xml_attributes[:hesa_id])
        expect(trainee.first_names).to eq(itt_record_xml_attributes[:first_names])
        expect(trainee.last_name).to eq(itt_record_xml_attributes[:last_name])
        expect(trainee.address_line_one).to eq(itt_record_xml_attributes[:address_line_one])
        expect(trainee.address_line_two).to eq(itt_record_xml_attributes[:address_line_two])
        expect(trainee.email).to eq(itt_record_xml_attributes[:email])
        expect(trainee.date_of_birth).to eq(Date.parse(itt_record_xml_attributes[:date_of_birth]))
        expect(trainee.gender).to eq("female")
        expect(trainee.trainee_id).to eq(itt_record_xml_attributes[:trainee_id])
        expect(trainee.nationalities.pluck(:name)).to include(nationality_name)
        expect(trainee.trn).to eq(itt_record_xml_attributes[:trn])
      end
    end

    context "trainee doesn't exist" do
      before do
        create(:provider, ukprn: itt_record_xml_attributes[:ukprn])
        described_class.call(itt_record_doc: itt_record_doc)
      end

      it "creates the trainee from HESA XML document" do
        expect(trainee.created_from_hesa).to be(true)
        expect(trainee.training_route).to eq(training_route)
        expect(trainee.hesa_id).to eq(itt_record_xml_attributes[:hesa_id])
        expect(trainee.first_names).to eq(itt_record_xml_attributes[:first_names])
        expect(trainee.last_name).to eq(itt_record_xml_attributes[:last_name])
        expect(trainee.address_line_one).to eq(itt_record_xml_attributes[:address_line_one])
        expect(trainee.address_line_two).to eq(itt_record_xml_attributes[:address_line_two])
        expect(trainee.email).to eq(itt_record_xml_attributes[:email])
        expect(trainee.date_of_birth).to eq(Date.parse(itt_record_xml_attributes[:date_of_birth]))
        expect(trainee.gender).to eq("female")
        expect(trainee.trainee_id).to eq(itt_record_xml_attributes[:trainee_id])
        expect(trainee.nationalities.pluck(:name)).to include(nationality_name)
        expect(trainee.trn).to eq(itt_record_xml_attributes[:trn])
      end
    end
  end
end
