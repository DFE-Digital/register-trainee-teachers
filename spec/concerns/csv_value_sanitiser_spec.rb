# frozen_string_literal: true

require "rails_helper"

describe CsvValueSanitiser do
  describe "#safe?" do
    let(:good_value) { "foo" }
    let(:date_value_str) { "2021-09-15 12:52:00 +0100" }
    let(:date_value) { Time.zone.parse(date_value_str) }

    let(:begins_with_equals) { "=foo" }
    let(:begins_with_plus) { "+foo" }
    let(:begins_with_minus) { "-foo" }
    let(:begins_with_at) { "@foo" }
    let(:begins_with_tab) { "\tfoo" }
    let(:begins_with_carriage_return) { "\rfoo" }

    specify { expect(described_class.new(good_value)).to be_safe }
    specify { expect(described_class.new(date_value_str)).to be_safe }
    specify { expect(described_class.new(date_value)).to be_safe }

    specify { expect(described_class.new(nil)).to be_safe }
    specify { expect(described_class.new("")).to be_safe }

    specify { expect(described_class.new(begins_with_equals)).not_to be_safe }
    specify { expect(described_class.new(begins_with_plus)).not_to be_safe }
    specify { expect(described_class.new(begins_with_minus)).not_to be_safe }
    specify { expect(described_class.new(begins_with_at)).not_to be_safe }
    specify { expect(described_class.new(begins_with_tab)).not_to be_safe }
    specify { expect(described_class.new(begins_with_carriage_return)).not_to be_safe }
  end

  describe "#sanitise" do
    let(:good_input) { "60147" }

    let(:bad_input_one) { '=1+2";=1+2' }
    let(:escaped_output_one) { %q("'=1+2"";=1+2") }

    let(:bad_input_two) { %q(=1+2'" ;,=1+2) }
    let(:escaped_output_two) { %q("'=1+2'"" ;,=1+2") }

    specify { expect(described_class.new(good_input).sanitise).to eq(good_input) }

    specify { expect(described_class.new(bad_input_one).sanitise).to eq(escaped_output_one) }
    specify { expect(described_class.new(bad_input_two).sanitise).to eq(escaped_output_two) }
  end
end
