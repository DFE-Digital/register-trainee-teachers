# frozen_string_literal: true

require "rails_helper"

describe Cacheable do
  let(:dummy_class) do
    Class.new { include Cacheable }.tap do |klass|
      klass.const_set(:FORM_SECTION_KEYS, %i[contact_details])
    end
  end

  let(:id) { 1 }
  let(:key) { :contact_details }
  let(:values) { { "email" => "trainee@example.com" } }

  describe "#get" do
    context "when the entry exists in Redis" do
      before do
        dummy_class.set(id, key, values)
      end

      it "returns the stored value" do
        expect(dummy_class.get(id, key)).to eq(values)
      end

      it "counts a redis hit" do
        expect(Yabeda.form_store.reads_total).to receive(:increment).with({ key: key, outcome: :redis_hit })

        dummy_class.get(id, key)
      end
    end

    context "when the entry does not exist" do
      it "returns nil" do
        expect(dummy_class.get(id, key)).to be_nil
      end

      it "counts a miss" do
        expect(Yabeda.form_store.reads_total).to receive(:increment).with({ key: key, outcome: :miss })

        dummy_class.get(id, key)
      end
    end
  end

  describe "#set" do
    it "counts a write to redis" do
      expect(Yabeda.form_store.writes_total).to receive(:increment).with({ key: key, backend: :redis })

      dummy_class.set(id, key, values)
    end

    context "without a valid form section key" do
      it "raises an error and counts nothing" do
        expect(Yabeda.form_store.writes_total).not_to receive(:increment)

        expect { dummy_class.set(id, :not_a_form_section, values) }.to raise_error(described_class::InvalidKeyError)
      end
    end
  end
end
