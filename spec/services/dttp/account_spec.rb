# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe Account do
    let(:account_data) do
      {
        "name" => "Myimaginary University",
        "modifiedon" => "2019-09-12T13:09:52Z",
      }
    end

    subject { described_class.new(account_data: account_data) }

    describe "methods" do
      it "#name" do
        expect(subject.name).to eq("Myimaginary University")
      end

      it "#last_updated" do
        expect(subject.last_updated).to eq("2019-09-12T13:09:52Z")
      end
    end
  end
end
