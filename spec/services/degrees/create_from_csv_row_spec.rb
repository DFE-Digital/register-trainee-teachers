# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe CreateFromCsvRow do
    subject(:service) { described_class.call(trainee: trainee, csv_row: csv.first) }

    let(:trainee) { create :trainee }
    let(:degree) { trainee.degrees.first }
    let(:csv) do
      CSV.read(
        file_fixture("hpitt_degree_import.csv").to_path,
        headers: true,
        encoding: "ISO-8859-1",
        header_converters: ->(f) { f&.strip },
      )
    end

    describe "#call" do
      it "attaches a degree to the trainee" do
        service
        expect(degree.subject).to eql "Philosophy"
      end
    end
  end
end
