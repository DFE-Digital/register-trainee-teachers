# frozen_string_literal: true

require "rails_helper"

RSpec.describe SetHesaTestRecords do
  describe "#call" do
    subject { described_class.call }

    let(:george_data) { { trn: "3001586", slug: "4RwkB5YADdBbAVMcLJ8cgSaL", first_names: "George", last_name: "Harrison" } }
    let(:ringo_data) { { trn: "3001587", slug: "Bcyx6hB4kd9AxRtK3jYdkTEo", first_names: "Ringo", last_name: "Starr" } }
    let(:john_data) { { trn: "3001588", slug: "6wk4nGs8BnLtvgniu593uHau", first_names: "John", last_name: "Lennon" } }
    let!(:provider) { create(:provider, ukprn: "10007140") }

    it "creates George, Ringo, and John with the correct attributes" do
      subject

      george = Trainee.find_by(trn: george_data[:trn])
      ringo = Trainee.find_by(trn: ringo_data[:trn])
      john = Trainee.find_by(trn: john_data[:trn])

      expect(george).to have_attributes(
        trn: george_data[:trn],
        slug: george_data[:slug],
        first_names: george_data[:first_names],
        last_name: george_data[:last_name],
      )

      expect(ringo).to have_attributes(
        trn: ringo_data[:trn],
        slug: ringo_data[:slug],
        first_names: ringo_data[:first_names],
        last_name: ringo_data[:last_name],
      )

      expect(john).to have_attributes(
        trn: john_data[:trn],
        slug: john_data[:slug],
        first_names: john_data[:first_names],
        last_name: john_data[:last_name],
      )
    end
  end
end
